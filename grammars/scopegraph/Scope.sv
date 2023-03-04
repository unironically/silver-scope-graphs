grammar scopegraph;

nonterminal Graph_sg;
nonterminal Scope_sg;
nonterminal Scopes_sg;

nonterminal Decl_sg;
nonterminal Decls_sg;

nonterminal Ref_sg;
nonterminal Refs_sg;

{-====================-}

inherited attribute parent :: Maybe<Decorated Scope_sg> occurs on Scope_sg, Scopes_sg;
inherited attribute scope :: Decorated Scope_sg occurs on Decl_sg, Decls_sg, Ref_sg, Refs_sg;

inherited attribute qid_imp :: Maybe<Decorated Ref_sg> occurs on Scope_sg;

synthesized attribute imps :: [Decorated Ref_sg] occurs on Ref_sg, Refs_sg, Scope_sg;
synthesized attribute iqid_imps :: [Decorated Ref_sg] occurs on Ref_sg, Refs_sg, Scope_sg;

synthesized attribute assoc_scope :: Maybe<Scope_sg> occurs on Decl_sg;

{-====================-}

abstract production mk_graph
g::Graph_sg ::= root::Scope_sg
{
  root.parent = nothing ();
  root.qid_imp = nothing ();
}

{-====================-}

abstract production mk_scope
s::Scope_sg ::= decls::Decls_sg refs::Refs_sg children::Scopes_sg
{
  decls.scope = s;
  refs.scope = s;
  children.parent = just (s);

  s.imps = case s.qid_imp of nothing () -> refs.iqid_imps | just (r) -> r::refs.iqid_imps end;
  s.iqid_imps = [];
}

abstract production mk_scope_qid
s::Scope_sg ::= ref::Ref_sg
{
  ref.scope = s;
  s.imps = case s.qid_imp of nothing () -> [] | just (r) -> [r] end;
  s.iqid_imps = ref.iqid_imps;
}


abstract production mk_decl
d::Decl_sg ::= id::String
{
  d.assoc_scope = nothing ();
}


abstract production mk_decl_assoc
d::Decl_sg ::= id::String s::Scope_sg
{
  s.parent = just (d.scope);
  s.qid_imp = nothing ();
  d.assoc_scope = just (s);
}


abstract production mk_ref
r::Ref_sg ::= id::String
{
  r.iqid_imps = [];
  r.imps = [];
}

abstract production mk_imp
r::Ref_sg ::= id::String
{
  r.iqid_imps = [r];
  r.imps = [];
}

abstract production mk_ref_qid
r::Ref_sg ::= id::String s::Scope_sg
{
  r.iqid_imps = s.iqid_imps;
  r.imps = [r];
  
  s.parent = nothing ();
  s.qid_imp = just (r);
}


{-====================-}

abstract production scope_cons
ss::Scopes_sg ::= s::Scope_sg st::Scopes_sg
{
  s.parent = ss.parent;
  s.qid_imp = nothing ();
  st.parent = ss.parent;
}

abstract production scope_nil
ss::Scopes_sg ::=
{
}

abstract production decl_cons
ds::Decls_sg ::= d::Decl_sg dt::Decls_sg
{
  d.scope = ds.scope;
  dt.scope = ds.scope;
}

abstract production decl_nil
ds::Decls_sg ::= 
{
}

abstract production ref_cons
rs::Refs_sg ::= r::Ref_sg rt::Refs_sg
{
  r.scope = rs.scope;
  rt.scope = rs.scope;

  rs.iqid_imps = r.iqid_imps ++ rt.iqid_imps;
  rs.imps = r.imps ++ rt.imps;
}

abstract production ref_nil
rs::Refs_sg ::= 
{
  rs.iqid_imps = [];
  rs.imps = [];
}

{-====================-}

function combine_decls
Decls_sg ::= ds1::Decls_sg ds2::Decls_sg
{
  return
    case ds1 of
    | decl_nil () -> ds2
    | decl_cons (d, dt) -> decl_cons (d, combine_decls (dt, ds2))
    end;
}

function combine_refs
Refs_sg ::= rs1::Refs_sg rs2::Refs_sg
{
  return
    case rs1 of
    | ref_nil () -> rs2
    | ref_cons (r, rt) -> ref_cons (r, combine_refs (rt, rs2))
    end;
}