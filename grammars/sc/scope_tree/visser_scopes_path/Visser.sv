grammar scope_tree:visser_scopes_path;

imports scope_tree:ast;

{- This is a revision of the algorithm in `visser` so that `res`
   computes a scopes_path of type `[ [Decorated Scope] ]` and then
   extracts the visible declarations from that.


   This replaces the `shadow` function with one that keeps all the
   scopes around, but `res` will just look for the declarations in
   the first scope that has any of the sought after name.
 -}


-- `resolve` is the function called from the testing harness
-- in the `testing` grammar
function resolve
[(String, Integer)] ::= r::(String, Integer) s::ScopeGraph
{
  return map (get_name_index_dcl, res ([], get_decorated_ref(r, s)));
}


-- `res` is the top-level function in Figure 18.
function res
[Decorated Dcl] ::= 
  seen_I::[Decorated Ref] x::Decorated Ref
{
  return case dropWhile (null, dcls_by_reachability) of
         | [] -> []
         | visible_dcls::_ -> visible_dcls
         end;

  local dcls_from_a_scope :: ([Decorated Dcl] ::= Decorated Scope)
    = \ s::Decorated Scope ->
          filter(\d::Decorated Dcl -> d.name == x.name, s.dcls);

  local dcls_from_equal_scopes :: ([Decorated Dcl] ::= [Decorated Scope])
    = \ ds::[Decorated Scope] ->
        concat (map (dcls_from_a_scope, ds));
 
  local dcls_by_reachability :: [ [Decorated Dcl] ]
    = map (dcls_from_equal_scopes, env_V (x::seen_I, [], x.parent));
}

function env_V
[ [Decorated Scope] ] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return env_L (seen_I, seen_S, s) ++ env_P (seen_I, seen_S, s);
}

function env_L
[ [Decorated Scope] ] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return env_D (seen_I, seen_S, s) :: env_I (seen_I, seen_S, s) :: [];
}

function env_D
[Decorated Scope] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return
    if containsBy (scope_id_eq, s, seen_S)
    then []
    else [s];
}

function env_I
[Decorated Scope] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return
    if containsBy (scope_id_eq, s, seen_S)
    then []
    else  all_imported_dcls;

  local unseen_imports :: [Decorated Ref] =
    filter (\i::Decorated Ref -> ! (containsBy(ref_id_eq, i, seen_I)),
            s.imps);
 
  local resolved_dcls :: [Decorated Dcl] =
    concat (map (res (seen_I, _), unseen_imports));

  local imported_scopes :: [Decorated Scope] =
    filterMap (\d::Decorated Dcl -> d.assoc_scope, resolved_dcls);

  local all_imported_dcls :: [Decorated Dcl] =
    concat (map (env_L (seen_I, s::seen_S, _), imported_scopes));

}

function env_P
[ [Decorated Scope] ] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return
    if containsBy (scope_id_eq, s, seen_S)
    then []
    else case s.scope_parent of
         | nothing() -> []
         | just(p) -> env_V (seen_I, s :: seen_S, p)
         end;

}






