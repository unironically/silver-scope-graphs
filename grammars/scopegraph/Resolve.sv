grammar scopegraph;


----------------
-- Functions corresponding to the scope graphs resolution algorithm

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
  return filter ((\s::Decorated Declaration<a> -> s.identifier == reference.identifier), 
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return merge_declarations_with_shadowing (env_l (seen_imports, seen_scopes, current_scope), 
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return merge_declarations_with_shadowing (env_d (seen_imports, seen_scopes, current_scope), 
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return 
    if containsBy ((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), current_scope, seen_scopes)
    then []
    else map((\thing::(String, Decorated Declaration<a>) -> snd(thing)), current_scope.declarations);
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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return 
    if (containsBy ((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), current_scope, seen_scopes))
    then []
    else 

      -- Get all imports of current scope, minus the ones already seen
      let imp_list::[Decorated Usage<a>] = removeAllBy((\left::Decorated Usage<a> right::Decorated Usage<a> -> left.identifier == right.identifier), seen_imports, map((\thing::(String, Decorated Usage<a>) -> snd(thing)), current_scope.imports)) in

      -- Generate a list of declarations by resolving each of the known imports in the current scope
      let res_list::[Decorated Declaration<a>] = foldl((\acc::[Decorated Declaration<a>] thing::Decorated Usage<a> -> acc ++ resolve(seen_imports, thing)), [], imp_list) in

      -- Get all the 'associated scope' nodes from the list generated above
      let scope_list::[Decorated Scope<a>] = foldl((\acc::[Decorated Scope<a>] thing::Decorated Declaration<a> -> acc ++ (case thing.associated_scope of | nothing() -> [] | just(p) -> [p] end)), [], res_list) in

      -- Union the result of calling env_l on each of the scopes found above, adding the current scope to the seen scopes list
      let last_list::[Decorated Declaration<a>] = 
      foldl((\acc::[Decorated Declaration<a>] thing::Decorated Scope<a> -> acc ++ env_l(seen_imports, seen_scopes ++ [current_scope], thing)), [], scope_list) in 

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
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return 
    case current_scope.parent of
      | nothing() -> []
      | just(p) -> if containsBy ((\left::Decorated Scope<a> right::Decorated Scope<a> -> 
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
  return unionBy (\mem_r::Decorated Declaration<a> mem_l::Decorated Declaration<a> -> 
    mem_r.identifier == mem_l.identifier, right , left);
}