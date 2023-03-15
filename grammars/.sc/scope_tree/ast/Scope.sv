grammar scope_tree:ast;

imports silver:langutil;
imports silver:langutil:pp;

nonterminal Scope;

synthesized attribute dcls :: [ Decorated Dcl ] occurs on Scope, Dcls;
synthesized attribute refs :: [ Decorated Ref ] occurs on Scope, Refs, Ref;
synthesized attribute imps :: [ Decorated Ref ] occurs on Scope, Refs, Ref;

inherited attribute parent :: Decorated Scope
  occurs on Ref, Refs, Dcl, Dcls;

inherited attribute scope_parent :: Maybe<Decorated Scope> occurs on Scope;

synthesized attribute name :: String occurs on Dcl, Ref;
synthesized attribute index :: Integer occurs on Dcl, Ref, Scope;

attribute pp occurs on Scope, Dcl, Dcls, Ref, Refs;

-- collecting things to the top for reporting
monoid attribute all_refs :: [Decorated Ref] occurs on Ref, Refs, Dcl, Dcls, Scope, ScopeGraph;
propagate all_refs on Ref, Refs, Dcl, Dcls, Scope, ScopeGraph;


nonterminal ScopeGraph with pp;

production root
r::ScopeGraph ::= main::Scope
{
  r.pp = main.pp;
  main.scope_parent = nothing(); 
}


production scope_tr
s::Scope ::= id::Integer dcls_tr::Dcls refs_tr::Refs imps_tr::Refs
{
  s.index = id;
  dcls_tr.parent = s; refs_tr.parent = s; imps_tr.parent = s;

  -- Decorated versions of the chilldren
  s.dcls = dcls_tr.dcls;
  s.refs = refs_tr.refs;
  s.imps = imps_tr.imps;

  -- Pretty Printing
  local dcls_doc :: Document =
     terminate (
       line(),
       map (\d::Decorated Dcl -> 
              ppConcat ([text(d.name), text(":"), pp(d.index),
                           text(" = ...")]),
           s.dcls)
        );

  s.pp = braces(
          nestlines(2,
            ppConcat( [
--              dcls_doc,
--              text("_ = "), ppImplode (cat (comma(), space()), 
--                                          map ( (.pp), s.refs)),
              line(),
              text("scope_paths"), line(),
--              pp(length(s.scope_paths)), line(),
--              pp(length(head(s.scope_paths))), line(),
--              pp(length(head(tail(s.scope_paths)))), line(),
              pp(length(s.imps)), line(),
--              pp(length(resolved_imports)), 
              line()
             ] )
            
         ));
}

--------------------------------------------------
nonterminal Dcl;
nonterminal Dcls;

{- Declarations have 
   - an associated scope, optionally
   - a reference to the AST node of the declaration
 -}
synthesized attribute assoc_scope :: Maybe <Decorated Scope> occurs on Dcl;

production dcl_tr
d::Dcl ::= n::String ind::Integer
{ d.name = n;
  d.index = ind;
  d.assoc_scope = nothing();
}

production dcl_scope_tr
d::Dcl ::= n::String ind::Integer s::Scope
{ d.name = n;
  d.index = ind;
  d.assoc_scope = just(s);
  s.scope_parent = just(d.parent);
}


production dcl_nil
ds::Dcls ::=
{ ds.dcls = []; 
}

production dcl_cons
ds::Dcls ::= h::Dcl t::Dcls
{ ds.dcls = h :: t.dcls;
  h.parent = ds.parent;  t.parent = ds.parent;
}

--------------------------------------------------
nonterminal Ref;
nonterminal Refs;

production ref_tr
r::Ref ::= n::String ind::Integer
{ r.name = n;
  r.index = ind;
  r.pp = ppConcat ([text(n), text(":"), pp(ind)]);
  r.refs = [r];
  r.imps = [];

  r.all_refs <- [r];
}


production imp_tr
i::Ref ::= n::String ind::Integer
{ i.name = n;
  i.index = ind;
  i.refs = [];
  i.imps = [i];

  i.all_refs <- [i];
}


production ref_nil
rs::Refs ::=
{
  rs.refs = [];
  rs.imps = [];
}

production ref_cons
rs::Refs ::= h::Ref t::Refs
{
  rs.refs = h.refs ++ t.refs;
  rs.imps = h.imps ++ t.imps;

  h.parent = rs.parent;
  t.parent = rs.parent;
}

