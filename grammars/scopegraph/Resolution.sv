grammar scopegraph;

function resolve_visser
[Decorated Decl] ::= 
  seen_imports::[Decorated Ref] 
  r::Decorated Ref
{
  return filter((\s::Decorated Decl -> s.name == r.name), 
    env_v (r::seen_imports, [], r.parent));
}

function env_v
[Decorated Decl] ::= 
  seen_imports::[Decorated Ref] 
  seen_scopes::[Decorated Scope] 
  current_scope::Decorated Scope
{
  return merge_declarations_with_shadowing(env_l (seen_imports, seen_scopes, current_scope), 
    env_p (seen_imports, seen_scopes, current_scope));
}

function env_l
[Decorated Decl] ::= 
  seen_imports::[Decorated Ref] 
  seen_scopes::[Decorated Scope] 
  current_scope::Decorated Scope
{
  return merge_declarations_with_shadowing(env_d (seen_imports, seen_scopes, current_scope), 
    env_i (seen_imports, seen_scopes, current_scope));
}


function env_d
[Decorated Decl] ::= 
  seen_imports::[Decorated Ref] 
  seen_scopes::[Decorated Scope] 
  current_scope::Decorated Scope
{
  return 
    if check_seen_scopes(current_scope, seen_scopes)
    then []
    else current_scope.declsl;
}

function env_i
[Decorated Decl] ::= 
  seen_imports::[Decorated Ref] 
  seen_scopes::[Decorated Scope] 
  current_scope::Decorated Scope
{
  return 
    if check_seen_scopes(current_scope, seen_scopes)
    then []
    else 

      -- Get all imports of current scope, remove names already seen in seen_imports
      let imp_list::[Decorated Ref] = removeAllBy (
        (\left_imp::Decorated Ref right_imp::Decorated Ref
          -> left_imp.str == right_imp.str), 
        seen_imports,
        current_scope.impsl)
      in

      -- Resolve each of the known imports in the current scope collected from the above
      let imp_res_list::[Decorated Decl] = foldl (
        (\imp_res_list::[Decorated Decl] imp::Decorated Ref 
          -> imp_res_list ++ 
            resolve_visser(seen_imports, imp)),  -- this is where decorated will come in when time to implement
        [],
        imp_list)
      in

      -- Get all the 'associated scope' nodes from declarations in imp_res_list generated above
      let scope_list::[Decorated Scope] = foldl (
        (\scope_list::[Decorated Scope] decl::Decorated Decl 
          -> scope_list ++ case decl.assoc_scope of 
            | nothing() -> [] | just(p) -> [p] end), 
        [],
        imp_res_list)
      in

      -- Get results of calling env_l on each of the scopes found above, with the current scope in each seen scopes list
      let final_res_list::[Decorated Decl] = foldl (
        (\final_res_list::[Decorated Decl] scope::Decorated Scope 
          -> final_res_list ++ env_l(seen_imports, seen_scopes ++ [current_scope], scope)), 
        [],
        scope_list)
      in 

      final_res_list 
      
      end end end end;
}

function env_p
[Decorated Decl] ::= 
  seen_imports::[Decorated Ref] 
  seen_scopes::[Decorated Scope] 
  current_scope::Decorated Scope
{
  return 
    case current_scope.scope_parent of
      | nothing() -> []
      | just(p) -> 
        if check_seen_scopes(current_scope, seen_scopes)
        then []
        else env_v (seen_imports, current_scope::seen_scopes, p)
    end;
}

{-====================-}

function merge_declarations_with_shadowing
[Decorated Decl] ::= l::[Decorated Decl] r::[Decorated Decl]
{
  return unionBy(\mem_r::Decorated Decl mem_l::Decorated Decl -> 
    mem_r.name == mem_l.name, r , l);
}

function check_seen_scopes
Boolean ::= 
  cur_scope::Decorated Scope 
  seen_scopes::[Decorated Scope]
{
  return containsBy((\l::Decorated Scope r::Decorated Scope -> 
    l.name == r.name), cur_scope, seen_scopes);
}
