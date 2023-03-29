grammar scope_tree:visser2;

imports scope_tree:ast;

{- This is an implementation of Visser's resolution algorithm from
   Fig 18 of "A Theory of Name Resolution"

   It is intended to match that implementation as closely as possible
   and to provide local values with descriptive names make reading it
   a bit less difficult.
 -}

{-====================-}

aspect production mk_ref
r::Ref<d r> ::=   _
{
  r.resolutions <- resolve (r);
}

aspect production mk_imp
r::Ref<d r> ::=   _
{
  r.resolutions <- resolve (r);
}

aspect production mk_ref_qid
r::Ref<d r> ::=   _  qid_scope::Scope<d r> 
{
  r.resolutions <- resolve (r);
}

{-====================-}


-- `resolve` is the function called from the testing harness
-- in the `testing` grammar
function resolve
[Decorated Dcl<d r>] ::= r :: Decorated Ref<d r>
    -- r::(String, Integer) s::ScopeGraph
{
  return res ([], r);
}


-- `res` is the top-level function in Figure 18.
function res
[Decorated Dcl<d r>] ::= 
  seen_I::[Decorated Ref<d r>] x::Decorated Ref<d r>
{
  return filter (\d::Decorated Dcl<d r> -> d.name == x.name,
                 env_V (x::seen_I, [], x.scope));
}

function env_V
[Decorated Dcl<d r>] ::= 
  seen_I::[Decorated Ref<d r>] seen_S::[Decorated Scope<d r>] s::Decorated Scope<d r>
{
  return shadow (env_L (seen_I, seen_S, s), env_P (seen_I, seen_S, s));
}

function env_L
[Decorated Dcl<d r>] ::= 
  seen_I::[Decorated Ref<d r>] seen_S::[Decorated Scope<d r>] s::Decorated Scope<d r>
{
  return shadow (env_D (seen_I, seen_S, s), env_I (seen_I, seen_S, s));
}

function env_D
[Decorated Dcl<d r>] ::= 
  seen_I::[Decorated Ref<d r>] seen_S::[Decorated Scope<d r>] s::Decorated Scope<d r>
{
  return
    if containsBy (scope_name_eq, s, seen_S)
    then []
    else s.decls;
}

function env_I
[Decorated Dcl<d r>] ::= 
  seen_I::[Decorated Ref<d r>] seen_S::[Decorated Scope<d r>] s::Decorated Scope<d r>
{
  return
    if containsBy (scope_name_eq, s, seen_S)
    then []
    else  all_imported_dcls;

  local unseen_imports :: [Decorated Ref<d r>] =
    filter (\i::Decorated Ref<d r> -> ! (containsBy(ref_id_eq, i, seen_I)),
            s.imps);
 
  local resolved_dcls :: [Decorated Dcl<d r>] =
    concat (map (res (seen_I, _), unseen_imports));

  local imported_scopes :: [Decorated Scope<d r>] =
    filterMap (\d::Decorated Dcl<d r> -> d.assoc_scope, resolved_dcls);

  local all_imported_dcls :: [Decorated Dcl<d r>] =
    concat (map (env_L (seen_I, s::seen_S, _), imported_scopes));

}

function env_P
[Decorated Dcl<d r>] ::= 
  seen_I::[Decorated Ref<d r>] seen_S::[Decorated Scope<d r>] s::Decorated Scope<d r>
{
  return
    if containsBy (scope_name_eq, s, seen_S)
    then []
    else case s.parent of
         | nothing() -> []
         | just(p) -> env_V (seen_I, s :: seen_S, p)
         end;

}

function shadow
[Decorated Dcl<d r>] ::= dcls_1::[Decorated Dcl<d r>] dcls_2::[Decorated Dcl<d r>]
{
  return
   dcls_1 ++ 
   filter (\d2::Decorated Dcl<d r> -> 
               ! (containsBy (dcl_name_eq, d2, dcls_1)), 
           dcls_2);
}





function ref_id_eq
Boolean ::= r1::Decorated Ref<d r> r2::Decorated Ref<d r>
{ return r1.str_id == r2.str_id;
}

function dcl_name_eq
Boolean ::= d1::Decorated Dcl<d r> d2::Decorated Dcl<d r>
{ return d1.name == d2.name;
}

{-
function scope_id_eq
Boolean ::= s1::Decorated Scope<d r> s2::Decorated Scope<d r>
{ return s1.index == s2.index;
}
-}

function scope_name_eq
Boolean ::= s1::Decorated Scope<d r> s2::Decorated Scope<d r>
{ return s1.name == s2.name;
}
