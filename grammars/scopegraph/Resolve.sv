grammar scopegraph;

---------------
-- Resolution algorithm:

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
[Decorated Declaration<d r>] ::= seen_imports::[Decorated Usage<d r>] reference::Decorated Usage<d r>
{
  return filter((\s::Decorated Declaration<d r> -> s.identifier == reference.identifier), 
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
[Decorated Declaration<d r>] ::= seen_imports::[Decorated Usage<d r>] seen_scopes::[Decorated Scope<d r>] 
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
[Decorated Declaration<d r>] ::= seen_imports::[Decorated Usage<d r>] seen_scopes::[Decorated Scope<d r>] 
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
[Decorated Declaration<d r>] ::= seen_imports::[Decorated Usage<d r>] seen_scopes::[Decorated Scope<d r>] 
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
[Decorated Declaration<d r>] ::= seen_imports::[Decorated Usage<d r>] seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return 
    if (containsBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), 
      current_scope, seen_scopes))
    then []
    else 

      -- Get all imports of current scope, remove names already seen in seen_imports
      let imp_list::[Decorated Usage<d r>] = removeAllBy(
        (\left_imp::Decorated Usage<d r> right_imp::Decorated Usage<d r>
          -> left_imp.identifier == right_imp.identifier), 
        seen_imports,
        current_scope.imports) 
      in

      -- Resolve each of the known imports in the current scope collected from the above
      let res_list::[Decorated Declaration<d r>] = foldl(
        (\res_list::[Decorated Declaration<d r>] import::Decorated Usage<d r> 
          -> res_list ++ resolve(seen_imports, import)), 
        [],
        imp_list)
      in

      -- Get all the 'associated scope' nodes from declarations in res_list generated above
      let scope_list::[Decorated Scope<d r>] = foldl(
        (\scope_list::[Decorated Scope<d r>] decl::Decorated Declaration<d r> 
          -> scope_list ++ (case decl.assoc_scope of | nothing() -> [] | just(p) -> [p] end)), 
        [],
        res_list)
      in

      -- Get results of calling env_l on each of the scopes found above, with the current scope in each seen scopes list
      let last_list::[Decorated Declaration<d r>] = foldl(
        (\last_list::[Decorated Declaration<d r>] scope::Decorated Scope<d r> 
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
[Decorated Declaration<d r>] ::= seen_imports::[Decorated Usage<d r>] seen_scopes::[Decorated Scope<d r>] 
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

function resolve
[Decorated Declaration<d r>] ::= ref::Decorated Usage<d r> cur_scope::Decorated Scope<d r>
{
  -- Check for any matching declarations in the current scope
  local attribute decls::[Decorated Declaration<d r>] = 
    filter((\decl::Decorated Declaration<d r> -> decl.identifier == ref.identifier), cur_scope.declarations);

  -- Check any imports that exist, call resolve on them
  local attribute imps::[Decorated Declaration<d r>] = foldl(
    (\acc::[Decorated Declaration<d r>] cur::Decorated Declaration<d r> -> 
      case cur.assoc_scope of | nothing() -> [] | just(s) -> resolve(ref, s) end),
    [],
    foldl(
      (\acc::[Decorated Declaration<d r>] cur::Decorated Usage<d r> -> acc ++ cur.resolutions),
      [],
      filter((\imp::Decorated Usage<d r> -> imp.identifier != ref.identifier), cur_scope.imports)
    )
  );
  
  -- recursive call on parent
  local attribute par::[Decorated Declaration<d r>] = case cur_scope.parent of
    | nothing() -> []
    | just(p) -> resolve(ref, p) -- Cases of circularity? Already seen this scope - never ending reolution?
  end;
  
  return merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par));
}
-}

@{-
 - Merges two lists of declarations such that the left-hand list shadows the right.
 -
 - @param left The left-hand list of declarations, which shadows the right.
 - @param right The shadowed right-hand list of declarations.
 - @return A list with all elements of the left and right lists, where the lefts shadows the rights.
-}
function merge_declarations_with_shadowing

[Decorated Declaration<d r>] ::= left::[Decorated Declaration<d r>] right::[Decorated Declaration<d r>]
{
  return unionBy(\mem_r::Decorated Declaration<d r> mem_l::Decorated Declaration<d r> -> 
    mem_r.identifier == mem_l.identifier, right , left);
}


----------------
-- Resolution paths:

nonterminal Path<d r> with start<d r>, final<d r>;

synthesized attribute start<d r>::Decorated Usage<d r>;
synthesized attribute final<d r>::Decorated Declaration<d r>;

@{-
 - Constructing a path node.
 -
 - @param start The usage being resolved in the path.
 - @param final The declaration resolved to in the path.
-}
abstract production cons_path
top::Path<d r> ::= start::Decorated Usage<d r> final::Decorated Declaration<d r>
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
  | h::t -> "Found resolution: " ++ h.start.to_string ++ " --> " ++ h.final.to_string ++ "\n" ++ 
    string_paths(t)
  | [] -> ""
  end;
}
