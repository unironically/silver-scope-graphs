grammar sc;

nonterminal Scope;

synthesized attribute dcls :: [ Decorated Dcl ] occurs on Scope, Dcls;
synthesized attribute refs :: [ Decorated Ref ] occurs on Scope, Refs, Ref;
synthesized attribute imps :: [ Decorated Ref ] occurs on Scope, Refs, Ref;

inherited attribute parent :: Decorated Scope occurs on Refs, Ref;

synthesized attribute resolutions :: [ Decorated Dcl ] occurs on Ref;

production scope_tr
s::Scope ::= dcls_tr::Dcls refs_tr::Refs imps_tr::Refs
{
  s.dcls = dcls_tr.dcls;
  s.refs = refs_tr.refs;
  s.imps = imps_tr.imps;

  refs_tr.parent = s;
}

--------------------------------------------------
nonterminal Dcl;
nonterminal Dcls;

production dcl_tr
d::Dcl ::= n::String
{
}

production dcl_scope_tr
d::Dcl ::= n::String s::Scope
{
}


production dcl_nil
ds::Dcls ::=
{ ds.dcls = []; 
}

production dcl_cons
ds::Dcls ::= h::Dcl t::Dcls
{
  ds.dcls = h :: t.dcls;
}

--------------------------------------------------
nonterminal Ref;
nonterminal Refs;

production ref_tr
r::Ref ::= n::String
{
  r.refs = [r];
  r.imps = [];

  r.scope_path =

}


production imp_tr
i::Ref ::= n::String
{
  i.refs = [];
  i.imps = [i];
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
