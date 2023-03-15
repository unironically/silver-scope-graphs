grammar scope_tree:visser;

imports scope_tree:ast;

{- This is an implementation of Visser's resolution algorithm from
   Fig 18 of "A Theory of Name Resolution"

   It is intended to match that implementation as closely as possible
   and to provide local values with descriptive names make reading it
   a bit less difficult.
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
  return filter (\d::Decorated Dcl -> d.name == x.name,
                 env_V (x::seen_I, [], x.parent));
}

function env_V
[Decorated Dcl] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return shadow (env_L (seen_I, seen_S, s), env_P (seen_I, seen_S, s));
}

function env_L
[Decorated Dcl] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return shadow (env_D (seen_I, seen_S, s), env_I (seen_I, seen_S, s));
}

function env_D
[Decorated Dcl] ::= 
  seen_I::[Decorated Ref] seen_S::[Decorated Scope] s::Decorated Scope
{
  return
    if containsBy (scope_id_eq, s, seen_S)
    then []
    else s.dcls;
}

function env_I
[Decorated Dcl] ::= 
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
[Decorated Dcl] ::= 
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

function shadow
[Decorated Dcl] ::= dcls_1::[Decorated Dcl] dcls_2::[Decorated Dcl]
{
  return
   dcls_1 ++ 
   filter (\d2::Decorated Dcl -> 
               ! (containsBy (dcl_name_eq, d2, dcls_1)), 
           dcls_2);
}





