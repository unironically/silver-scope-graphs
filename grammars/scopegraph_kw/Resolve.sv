grammar scopegraph_kw;


----------------
-- Functions corresponding to the scope graphs resolution algorithm:

@{-
 - The entry point function for the resolution algorithm.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param reference The reference to resolve.
 - @return The list of declarations found when the reference is resolved.
-}
function resolve
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] reference::Decorated Ref<d r>
{
  return filter((\s::Decorated Decl<d r> -> s.identifier == reference.identifier), 
    env_v ([reference] ++ seen_imports, [], reference.in_scope));
}

@{-
 - The second resolution function, where declarations are collected from calling env_l and env_p.
 - The declarations found by calling env_l shadow those found from calling env_p.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param seen_scopes The list of scopes that the algorithm has already visited.
 - @param current_scope The current scope we look for declarations inside.
 - @return The combined list of delcarations from env_l and env_p.
-}
function env_v
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return merge_declarations_with_shadowing(env_l (seen_imports, seen_scopes, current_scope), 
    env_p (seen_imports, seen_scopes, current_scope));
}

@{-
 - The third resolution function, where declarations are collected from calling env_d and end_i.
 - The declarations found by calling env_d shadow those found from calling env_i.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param seen_scopes The list of scopes that the algorithm has already visited.
 - @param current_scope The current scope we look for declarations inside.
 - @return The combined list of delcarations from env_d and env_l.
-}
function env_l
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return merge_declarations_with_shadowing(env_d (seen_imports, seen_scopes, current_scope), 
    env_i (seen_imports, seen_scopes, current_scope));
}

@{-
 - The fourth resolution function, where declarations are collected from the current scope.
 - The declarations found by calling env_l shadow those found from calling env_p.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param seen_scopes The list of scopes that the algorithm has already visited.
 - @param current_scope The current scope we look for declarations inside.
 - @return The list of declarations for the current scope
-}
function env_d
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return 
    if containsBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), 
      current_scope, seen_scopes)
    then []
    else current_scope.declarations;
}

@{-
 - The fifth resolution function, where imported declarations are found by recursively calling
 - the resolve function to resolve references which point to imports.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param seen_scopes The list of scopes that the algorithm has already visited.
 - @param current_scope The current scope we look for declarations inside.
 - @return The list of imported declarations.
-}
function env_i
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return 
    if (containsBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), 
      current_scope, seen_scopes))
    then []
    else 

      -- Get all imports of current scope, remove names already seen in seen_imports
      let imp_list::[Decorated Ref<d r>] = removeAllBy(
        (\left_imp::Decorated Ref<d r> right_imp::Decorated Ref<d r>
          -> left_imp.identifier == right_imp.identifier), 
        seen_imports,
        current_scope.imports) 
      in

      -- Resolve each of the known imports in the current scope collected from the above
      let res_list::[Decorated Decl<d r>] = foldl(
        (\res_list::[Decorated Decl<d r>] import::Decorated Ref<d r> 
          -> res_list ++ resolve(seen_imports, import)), 
        [],
        imp_list)
      in

      -- Get all the 'associated scope' nodes from declarations in res_list generated above
      let scope_list::[Decorated Scope<d r>] = foldl(
        (\scope_list::[Decorated Scope<d r>] decl::Decorated Decl<d r> 
          -> scope_list ++ (case decl.assoc_scope of | nothing() -> [] | just(p) -> [p] end)), 
        [],
        res_list)
      in

      -- Get results of calling env_l on each of the scopes found above, with the current scope in each seen scopes list
      let last_list::[Decorated Decl<d r>] = foldl(
        (\last_list::[Decorated Decl<d r>] scope::Decorated Scope<d r> 
          -> last_list ++ env_l(seen_imports, seen_scopes ++ [current_scope], scope)), 
        [],
        scope_list)
      in 

      last_list end end end end;
}

@{-
 - The sixth resolution function, where declarations are collected by calling env_v on the parent
 - scope of the current scope.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param seen_scopes The list of scopes that the algorithm has already visited.
 - @param current_scope The current scope we look for declarations inside.
 - @return The list of declarations found by searching inside of the parent scope.
-}
function env_p
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return 
    case current_scope.parent of
      | nothing() -> []
      | just(p) -> 
        if containsBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), 
          current_scope, seen_scopes)
        then 
          []
        else 
          env_v (seen_imports, current_scope::seen_scopes, p)
    end;
}

@{-
 - Resolves a reference to a set of declarations by first checking the immediate scope for
 - matching declarations, then all declarations visible through imports, then all those visible
 - by inheriting from the scope which is the parent of cur_scope.
 -
 - @param ref The usage whose declarations we are trying to resolve.
 - @param cur_scope The scope to search for valid declarations in.
 - @return A list of all declarations that ref resolves to.
-}
function resolve_new
[Decorated Decl<d r>] ::= 
  ref::Decorated Ref<d r> 
  cur_scope::Decorated Scope<d r> 
  seen_scopes::[Decorated Scope<d r>] 
  seen_imports::[Decorated Ref<d r>]
{

  local attribute new_seen_scopes::[Decorated Scope<d r>] = seen_scopes;-- ++ [cur_scope];
  local attribute new_seen_imports::[Decorated Ref<d r>] = seen_imports ++ [ref];

  -- Check for any matching declarations in the current scope
  local attribute decls::[Decorated Decl<d r>] = filter((\decl::Decorated Decl<d r> -> decl.identifier == ref.identifier), cur_scope.declarations);
  
  -- Check any imports that exist, call resolve on them
  local attribute imps::[Decorated Decl<d r>] = foldl(
    (\acc::[Decorated Decl<d r>] cur::Decorated Decl<d r> -> acc ++ 
      case cur.assoc_scope of | nothing() -> [] | just(s) -> filter((
        \decl::Decorated Decl<d r> -> decl.identifier == ref.identifier
      ), resolve_new(ref, s, new_seen_scopes, new_seen_imports)) end),
    [],
    foldl(
      (\acc::[Decorated Decl<d r>] cur::Decorated Ref<d r> -> 
        acc ++ let new_cur::Ref<d r> = new(cur) in (decorate new_cur with {
          seen_imports = new_seen_imports; 
          in_scope = cur.in_scope;
          line = cur.line;
          column = cur.column;
          str = cur.str;
          identifier = cur.identifier;
          resolutions = cur.resolutions; 
          errors = cur.errors;
          paths = cur.paths;}).resolutions end
      ),
      [],
      removeAllBy(
        (\left::Decorated Ref<d r> right::Decorated Ref<d r> -> left.str == right.str),
        new_seen_imports,
        cur_scope.imports
      )
    )
  );
  
  -- recursive call on parent
  local attribute par::[Decorated Decl<d r>] = case cur_scope.parent of
    | nothing() -> []
    | just(p) -> filter((\decl::Decorated Decl<d r> -> decl.identifier == ref.identifier), resolve_new(ref, p, new_seen_scopes, seen_imports))
  end;
  
  --return if check_seen_scopes(cur_scope, seen_scopes) then 
    --merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par))
    return if (length(decls) > 0) then
      decls
    else if (length(imps) > 0) then
      imps
    else
      par;
  --else 
  --  [];
}

function check_seen_scopes
Boolean ::= cur_scope::Decorated Scope<d r> seen_scopes::[Decorated Scope<d r>]
{
  return containsBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), cur_scope, seen_scopes);
}


@{-
 - Merges two lists of declarations such that the left-hand list shadows the right.
 -
 - @param left The left-hand list of declarations, which shadows the right.
 - @param right The shadowed right-hand list of declarations.
 - @return A list with all elements of the left and right lists, where the lefts shadows the rights.
-}
function merge_declarations_with_shadowing

[Decorated Decl<d r>] ::= left::[Decorated Decl<d r>] right::[Decorated Decl<d r>]
{
  return unionBy(\mem_r::Decorated Decl<d r> mem_l::Decorated Decl<d r> -> 
    mem_r.identifier == mem_l.identifier, right , left);
}


----------------
-- Resolution paths:

nonterminal Path<d r> with start<d r>, final<d r>;

synthesized attribute start<d r>::Decorated Ref<d r>;
synthesized attribute final<d r>::Decorated Decl<d r>;

@{-
 - Constructing a path node.
 -
 - @param start The usage being resolved in the path.
 - @param final The declaration resolved to in the path.
-}
abstract production cons_path
top::Path<d r> ::= start::Decorated Ref<d r> final::Decorated Decl<d r>
{
  top.start = start;
  top.final = final;
}

@{-
 - Convert a list of resolution paths to a string.
 -
 - @param list The list of resolution paths.
 - @return A string representing all of the resolution paths.
-}
function string_paths
String ::= list::[Decorated Path<d r>]
{
  return case list of 
  | h::t -> "Found resolution: " ++ h.start.str ++ " --> " ++ h.final.str ++ "\n" ++ 
    string_paths(t)
  | [] -> ""
  end;
}
