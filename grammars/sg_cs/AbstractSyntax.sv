grammar sg_cs;

nonterminal Program;
nonterminal NodeList;
nonterminal Decls;
nonterminal Refs;
nonterminal Decl;
nonterminal Qid;
nonterminal Name;

{-====================-} 

synthesized attribute graph::sg:Graph<Name> occurs on Program;

synthesized attribute decls::sg:Decls<Name> occurs on NodeList, Decls;
synthesized attribute refs::sg:Refs<Name> occurs on NodeList, Refs;
synthesized attribute children::sg:Scopes<Name> occurs on NodeList;

inherited attribute last_is_imp::Boolean occurs on Qid;

synthesized attribute ref::sg:Ref<Name> occurs on Qid;

{- required by scope graph abstract syntax -}
attribute sg:name occurs on Name;
flowtype sg:name {} on Name;

{-====================-}

{- Program -}

abstract production program
p::Program ::= sl::NodeList
{
  local g::sg:Graph<Name> = sg:mk_graph (s);
  local s::sg:Scope<Name> = sg:mk_scope (sl.decls, sl.refs, sl.children);
  p.graph = g;
}

{- Node List -}

abstract production nodelist_decls
sl::NodeList ::= dl::Decls slt::NodeList
{
  sl.decls = sg:combine_decls (dl.decls, slt.decls);
  sl.refs = slt.refs;
  sl.children = slt.children;
}

abstract production decl_module
sl::NodeList ::= id::Name sub::NodeList slt::NodeList
{
  local s::sg:Scope<Name> = sg:mk_scope (sub.decls, sub.refs, sub.children);
  local d::sg:Decl<Name> = sg:mk_decl_assoc (id, s);
  sl.decls = sg:decl_cons (d, slt.decls);
  sl.refs = slt.refs;
  sl.children = slt.children;
}

abstract production nodelist_refs
sl::NodeList ::= rl::Refs slt::NodeList
{
  sl.decls = slt.decls;
  sl.refs = sg:combine_refs (rl.refs, slt.refs);
  sl.children = slt.children;
}

abstract production nodelist_import
sl::NodeList ::= qid::Qid slt::NodeList
{
  sl.decls = slt.decls;
  sl.refs = sg:ref_cons (qid.ref, slt.refs);
  sl.children = slt.children;
  qid.last_is_imp = true;
}

abstract production nodelist_subscope
sl::NodeList ::= sub::NodeList slt::NodeList
{
  local s::sg:Scope<Name> = sg:mk_scope (sub.decls, sub.refs, sub.children);
  sl.decls = slt.decls;
  sl.refs = slt.refs;
  sl.children = sg:scope_cons (s, slt.children);
}

abstract production nodelist_nothing
sl::NodeList ::= 
{
  sl.decls = sg:decl_nil ();
  sl.refs = sg:ref_nil ();
  sl.children = sg:scope_nil ();
}

{- Decls -}

abstract production decls_comma
ds::Decls ::= id::Name dst::Decls
{
  local d::sg:Decl<Name> = sg:mk_decl (id);
  ds.decls = sg:decl_cons (d, dst.decls);
}

abstract production decls_last
ds::Decls ::= id::Name
{
  local d::sg:Decl<Name> = sg:mk_decl (id);
  ds.decls = sg:decl_cons (d, sg:decl_nil ());
}

{- Refs -}

abstract production refs_comma
rs::Refs ::= qid::Qid rst::Refs
{
  rs.refs = sg:ref_cons (qid.ref, rst.refs);
  qid.last_is_imp = false;
}

abstract production refs_last
rs::Refs ::= qid::Qid
{
  rs.refs = sg:ref_cons (qid.ref, sg:ref_nil ());
  qid.last_is_imp = false;
}

{- Qid -}

abstract production qid_dot
q::Qid ::= id::Name qt::Qid
{ propagate last_is_imp;
  local r::sg:Ref<Name> = sg:mk_ref_qid (id, s);
  local s::sg:Scope<Name> = sg:mk_scope_qid (qt.ref);
  q.ref = r;
}

abstract production qid_single
q::Qid ::= id::Name
{
  local r::sg:Ref<Name> = if q.last_is_imp then sg:mk_imp (id) else sg:mk_ref (id);
  q.ref = r;
}

abstract production name
n::Name ::= id::String
{
  n.sg:name = id;
}