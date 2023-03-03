grammar scopegraph;

nonterminal Program;
nonterminal NodeList;
nonterminal Decls;
nonterminal Refs;
nonterminal Decl;
nonterminal Qid;

{-====================-}

synthesized attribute graph::Graph_sg occurs on Program;

synthesized attribute decls::Decls_sg occurs on NodeList, Decls;
synthesized attribute refs::Refs_sg occurs on NodeList, Refs;
synthesized attribute children::Scopes_sg occurs on NodeList;

inherited attribute last_is_imp::Boolean occurs on Qid;

synthesized attribute ref::Ref_sg occurs on Qid;

{-====================-}

{- Program -}

abstract production program
p::Program ::= sl::NodeList
{
  local g::Graph_sg = mk_graph (s);
  local s::Scope_sg = mk_scope (sl.decls, sl.refs, sl.children);
  p.graph = g;
}

{- Node List -}

abstract production nodelist_decls
sl::NodeList ::= dl::Decls slt::NodeList
{
  sl.decls = combine_decls (dl.decls, slt.decls);
  sl.refs = slt.refs;
  sl.children = slt.children;
}

abstract production decl_module
sl::NodeList ::= id::String sub::NodeList slt::NodeList
{
  local s::Scope_sg = mk_scope (sub.decls, sub.refs, sub.children);
  local d::Decl_sg = mk_decl_assoc (id, s);
  sl.decls = decl_cons (d, slt.decls);
  sl.refs = slt.refs;
  sl.children = slt.children;
}

abstract production nodelist_refs
sl::NodeList ::= rl::Refs slt::NodeList
{
  sl.decls = slt.decls;
  sl.refs = combine_refs (rl.refs, slt.refs);
  sl.children = slt.children;
}

abstract production nodelist_import
sl::NodeList ::= qid::Qid slt::NodeList
{
  sl.decls = slt.decls;
  sl.refs = ref_cons (qid.ref, slt.refs);
  sl.children = slt.children;
  qid.last_is_imp = true;
}

abstract production nodelist_subscope
sl::NodeList ::= sub::NodeList slt::NodeList
{
  local s::Scope_sg = mk_scope (sub.decls, sub.refs, sub.children);
  sl.decls = slt.decls;
  sl.refs = slt.refs;
  sl.children = scope_cons (s, slt.children);
}

abstract production nodelist_nothing
sl::NodeList ::= 
{
  sl.decls = decl_nil ();
  sl.refs = ref_nil ();
  sl.children = scope_nil ();
}

{- Decls -}

abstract production decls_comma
ds::Decls ::= id::String dst::Decls
{
  local d::Decl_sg = mk_decl (id);
  ds.decls = decl_cons (d, dst.decls);
}

abstract production decls_last
ds::Decls ::= id::String
{
  local d::Decl_sg = mk_decl (id);
  ds.decls = decl_cons (d, decl_nil ());
}

{- Refs -}

abstract production refs_comma
rs::Refs ::= qid::Qid rst::Refs
{ 
  rs.refs = ref_cons (qid.ref, rst.refs);
  qid.last_is_imp = false;
}

abstract production refs_last
rs::Refs ::= qid::Qid
{
  rs.refs = ref_cons (qid.ref, ref_nil ());
  qid.last_is_imp = false;
}

{- Qid -}

abstract production qid_dot
q::Qid ::= id::String qt::Qid
{ propagate last_is_imp;
  local r::Ref_sg = mk_ref_qid (id, s);
  local s::Scope_sg = mk_scope_qid (qt.ref);
  q.ref = r;
}

abstract production qid_single
q::Qid ::= id::String
{
  local r::Ref_sg = if q.last_is_imp then mk_imp (id) else mk_ref (id);
  q.ref = r;
}
