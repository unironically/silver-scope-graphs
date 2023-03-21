grammar scope_tree:visser;

import scope_tree:ast;

{-====================-}

aspect production mk_ref
r::Ref<d r> ::= 
  _
{
  r.resolutions = resolve_visser ([], r);
}

aspect production mk_imp
r::Ref<d r> ::= 
  _
{
  r.resolutions = resolve_visser ([], r);
}

aspect production mk_ref_qid
r::Ref<d r> ::= 
  _
  s::Scope<d r> 
{
  r.resolutions = resolve_visser ([], r);
}

{-====================-}

function resolve_visser
[Decorated Decl<d r>] ::= 
  seen_imports::[Decorated Ref<d r>] 
  r::Decorated Ref<d r>
{
  return filter((\s::Decorated Decl<d r> -> s.id == r.id), 
    env_v (r::seen_imports, [], r.scope));
}

function env_v
[Decorated Decl<d r>] ::= 
  seen_imports::[Decorated Ref<d r>] 
  seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return merge_declarations_with_shadowing(env_l (seen_imports, seen_scopes, current_scope), 
    env_p (seen_imports, seen_scopes, current_scope));
}

function env_l
[Decorated Decl<d r>] ::= 
  seen_imports::[Decorated Ref<d r>] 
  seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return merge_declarations_with_shadowing(env_d (seen_imports, seen_scopes, current_scope), 
    env_i (seen_imports, seen_scopes, current_scope));
}

function env_d
[Decorated Decl<d r>] ::= 
  seen_imports::[Decorated Ref<d r>] 
  seen_scopes::[Decorated Scope<d r>] 
  current_scope::Decorated Scope<d r>
{
  return 
    if check_seen_scopes(current_scope, seen_scopes)
    then []
    else current_scope.decls;
}

function env_i
[Decorated Decl<d r>] ::= 
  seen_imports::[Decorated Ref<d r>] 
  seen_scopes::[Decorated Scope<d r>] 
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
      let imp_res_list::[Decorated Decl<d r>] = foldl (
        (\imp_res_list::[Decorated Decl<d r>] imp::Decorated Ref<d r>
          -> imp_res_list ++ 
            resolve_visser(seen_imports, imp)),  -- this is where decorated will come in when time to implement
        [],
        imp_list)
      in

      -- Get all the 'associated scope' nodes from declarations in imp_res_list generated above
      let scope_list::[Decorated Scope<d r>] = foldl (
        (\scope_list::[Decorated Scope<d r>] decl::Decorated Decl<d r>
          -> scope_list ++ case decl.assoc_scope of 
            | nothing() -> [] | just(p) -> [p] end), 
        [],
        imp_res_list)
      in

      -- Get results of calling env_l on each of the scopes found above, with the current scope in each seen scopes list
      let final_res_list::[Decorated Decl<d r>] = foldl (
        (\final_res_list::[Decorated Decl<d r>] scope::Decorated Scope<d r>
          -> final_res_list ++ env_l(seen_imports, seen_scopes ++ [current_scope], scope)), 
        [],
        scope_list)
      in 

      final_res_list 
      
      end end end end;
}

function env_p
[Decorated Decl<d r>] ::= 
  seen_imports::[Decorated Ref<d r>] 
  seen_scopes::[Decorated Scope<d r>] 
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

function merge_declarations_with_shadowing
[Decorated Decl<d r>] ::= l::[Decorated Decl<d r>] r::[Decorated Decl<d r>]
{
  return unionBy(\mem_r::Decorated Decl<d r> mem_l::Decorated Decl<d r> -> 
    mem_r.id == mem_l.id, r , l);
}

function check_seen_scopes
Boolean ::= 
  cur_scope::Decorated Scope<d r>
  seen_scopes::[Decorated Scope<d r>]
{
  return containsBy((\l::Decorated Scope<d r> r::Decorated Scope<d r> -> 
    l.id == r.id), cur_scope, seen_scopes);
}