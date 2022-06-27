grammar scopegraph;


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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] reference::Decorated Usage<a>
{
  return filter((\s::Decorated Declaration<a> -> s.identifier == reference.identifier), 
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] 
  current_scope::Decorated Scope<a>
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] 
  current_scope::Decorated Scope<a>
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] 
  current_scope::Decorated Scope<a>
{
  return 
    if containsBy((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), 
      current_scope, seen_scopes)
    then []
    else map((\thing::(String, Decorated Declaration<a>) -> snd(thing)), 
      current_scope.declarations);
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] 
  current_scope::Decorated Scope<a>
{
  return 
    if (containsBy((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), 
      current_scope, seen_scopes))
    then []
    else 

      -- Get all imports of current scope, remove names already seen in seen_imports
      let imp_list::[Decorated Usage<a>] = removeAllBy(
        (\left_imp::Decorated Usage<a> right_imp::Decorated Usage<a> 
          -> left_imp.identifier == right_imp.identifier), 
        seen_imports,
        map((\imp_pair::(String, Decorated Usage<a>) -> snd(imp_pair)), current_scope.imports)) 
      in

      -- Resolve each of the known imports in the current scope collected from the above
      let res_list::[Decorated Declaration<a>] = foldl(
        (\res_list::[Decorated Declaration<a>] import::Decorated Usage<a> 
          -> res_list ++ resolve(seen_imports, import)), 
        [],
        imp_list)
      in

      -- Get all the 'associated scope' nodes from declarations in res_list generated above
      let scope_list::[Decorated Scope<a>] = foldl(
        (\scope_list::[Decorated Scope<a>] decl::Decorated Declaration<a> 
          -> scope_list ++ (case decl.assoc_scope of | nothing() -> [] | just(p) -> [p] end)), 
        [],
        res_list)
      in

      -- Get results of calling env_l on each of the scopes found above, with the current scope in each seen scopes list
      let last_list::[Decorated Declaration<a>] = foldl(
        (\last_list::[Decorated Declaration<a>] scope::Decorated Scope<a> 
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] 
  current_scope::Decorated Scope<a>
{
  return 
    case current_scope.parent of
      | nothing() -> []
      | just(p) -> if containsBy((\left::Decorated Scope<a> right::Decorated Scope<a> -> 
        left.id == right.id), current_scope, seen_scopes)
        then []
        else env_v (seen_imports, current_scope::seen_scopes, p)
    end;
}

@{-
 - Merges two lists of declarations such that the left-hand list shadows the right.
 -
 - @param left The left-hand list of declarations, which shadows the right.
 - @param right The shadowed right-hand list of declarations.
 - @return A list with all elements of the left and right lists, where the lefts shadows the rights.
-}
function merge_declarations_with_shadowing
[Decorated Declaration<a>] ::= left::[Decorated Declaration<a>] right::[Decorated Declaration<a>]
{
  return unionBy(\mem_r::Decorated Declaration<a> mem_l::Decorated Declaration<a> -> 
    mem_r.identifier == mem_l.identifier, right , left);
}


----------------
-- Resolution paths:

nonterminal Path<a> with start<a>, final<a>;

synthesized attribute start<a>::Decorated Usage<a>;
synthesized attribute final<a>::Decorated Declaration<a>;

@{-
 - Constructing a path node.
 -
 - @param start The usage being resolved in the path.
 - @param final The declaration resolved to in the path.
-}
abstract production cons_path
top::Path<a> ::= start::Decorated Usage<a> final::Decorated Declaration<a>
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
String ::= list::[Decorated Path<a>]
{
  return case list of 
  | h::t -> "Found resolution: " ++ h.start.to_string ++ " --> " ++ h.final.to_string ++ "\n" ++ 
    string_paths(t)
  | [] -> ""
  end;
}