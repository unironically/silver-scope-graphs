grammar visseroriginal;

----------------
-- Functions corresponding to the scope graphs resolution algorithm:

@{-
 - The entry point function for the resolution algorithm.
 -
 - @param seen_imports The list of imports and references already seen.
 - @param reference The reference to resolve.
 - @return The list of declarations found when the reference is resolved.
-}
function resolve_visser
[Decorated Decl<d r>] ::= seen_imports::[Decorated Ref<d r>] reference::Decorated Ref<d r>
{
  return filter((\s::Decorated Decl<d r> -> s.name == reference.name), 
    env_v (reference::seen_imports, [], reference.in_scope));
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
    if check_seen_scopes(current_scope, seen_scopes)
    then []
    else current_scope.decls;
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
    if check_seen_scopes(current_scope, seen_scopes)
    then []
    else 

      -- Get all imports of current scope, remove names already seen in seen_imports
      let imp_list::[Decorated Ref<d r>] = removeAllBy (
        (\left_imp::Decorated Ref<d r> right_imp::Decorated Ref<d r>
          -> left_imp.str == right_imp.str), 
        seen_imports,
        current_scope.imps)
      in

      -- Resolve each of the known imports in the current scope collected from the above
      let res_list::[Decorated Decl<d r>] = foldl (
        (\res_list::[Decorated Decl<d r>] imp::Decorated Ref<d r> 
          -> res_list ++ 
            resolve_visser(seen_imports, imp)),  -- this is where decorated will come in when time to implement
        [],
        imp_list)
      in

      -- Get all the 'associated scope' nodes from declarations in res_list generated above
      let scope_list::[Decorated Scope<d r>] = foldl (
        (\scope_list::[Decorated Scope<d r>] decl::Decorated Decl<d r> 
          -> scope_list ++ case decl.assoc_scope of | nothing() -> [] | just(p) -> [p] end), 
        [],
        res_list)
      in

      -- Get results of calling env_l on each of the scopes found above, with the current scope in each seen scopes list
      let last_list::[Decorated Decl<d r>] = foldl (
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
        if check_seen_scopes(current_scope, seen_scopes)
        then []
        else env_v (seen_imports, current_scope::seen_scopes, p)
    end;
}

function check_seen_scopes
Boolean ::= cur_scope::Decorated Scope<d r> seen_scopes::[Decorated Scope<d r>]
{
  -- true if cur_scope is contained in seen_scopes
  return containsBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> 
    left.id == right.id), cur_scope, seen_scopes);
}

function merge_declarations_with_shadowing
[Decorated Decl<d r>] ::= left::[Decorated Decl<d r>] right::[Decorated Decl<d r>]
{
  return unionBy(\mem_r::Decorated Decl<d r> mem_l::Decorated Decl<d r> -> 
    mem_r.name == mem_l.name, right , left);
}