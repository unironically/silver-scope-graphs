grammar sg_cs;

nonterminal Program;
nonterminal NodeList;
nonterminal Decls;
nonterminal Refs;
nonterminal Decl;
nonterminal Qid;
nonterminal IdDecl;
nonterminal IdRef;

{-====================-} 

synthesized attribute graph::sg:Graph<IdDecl IdRef> occurs on Program;

synthesized attribute decls::sg:Decls<IdDecl IdRef> occurs on NodeList, Decls;
synthesized attribute refs::sg:Refs<IdDecl IdRef> occurs on NodeList, Refs;
synthesized attribute children::sg:Scopes<IdDecl IdRef> occurs on NodeList;

inherited attribute last_is_imp::Boolean occurs on Qid, IdRef;
synthesized attribute ref::sg:Ref<IdDecl IdRef> occurs on Qid, IdRef;

monoid attribute ress::[(Decorated sg:Ref<IdDecl IdRef>, Decorated sg:Decl<IdDecl IdRef>)] 
  occurs on Program, NodeList, Refs, Qid, IdRef;
propagate ress on Program, NodeList, Refs, Qid;

inherited attribute dec_graph::sg:Graph<IdDecl IdRef> 
  occurs on Program, NodeList, Refs, Qid, IdRef;
propagate dec_graph on NodeList, Refs, Qid; 

{- required by scope graph abstract syntax -}
attribute sg:str_id occurs on IdDecl, IdRef;
flowtype sg:str_id {} on IdDecl, IdRef;

attribute sg:name occurs on IdDecl, IdRef;
flowtype sg:name {} on IdDecl, IdRef;

attribute sg:index occurs on IdDecl, IdRef;
flowtype sg:index {} on IdDecl, IdRef;

{-====================-}

{- Program -}

abstract production program
p::Program ::= sl::NodeList
{
  local g::sg:Graph<IdDecl IdRef> = sg:mk_graph (s);
  local s::sg:Scope<IdDecl IdRef> = sg:mk_scope (sl.decls, sl.refs, sl.children);
  p.graph = g;
  sl.dec_graph = g;
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
sl::NodeList ::= id::IdDecl sub::NodeList slt::NodeList
{
  local s::sg:Scope<IdDecl IdRef> = sg:mk_scope (sub.decls, sub.refs, sub.children);
  local d::sg:Decl<IdDecl IdRef> = sg:mk_decl_assoc (id, s);
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
  local s::sg:Scope<IdDecl IdRef> = sg:mk_scope (sub.decls, sub.refs, sub.children);
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
ds::Decls ::= id::IdDecl dst::Decls
{
  local d::sg:Decl<IdDecl IdRef> = sg:mk_decl (id);
  ds.decls = sg:decl_cons (d, dst.decls);
}

abstract production decls_last
ds::Decls ::= id::IdDecl
{
  local d::sg:Decl<IdDecl IdRef> = sg:mk_decl (id);
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
q::Qid ::= id::IdRef qt::Qid
{ propagate last_is_imp;
  local s::sg:Scope<IdDecl IdRef> = sg:mk_scope_qid (qt.ref);
  q.ref = id.ref;
}

abstract production qid_single
q::Qid ::= id::IdRef
{ propagate last_is_imp;
  q.ref = id.ref;
}

{- Names -}

abstract production ref
n::IdRef ::= id::String
{
  local parts::[String] = explode ("_", id);
  n.sg:name = head(parts);
  n.sg:index = head(tail(parts));
  n.sg:str_id = id;


  local r::sg:Ref<IdDecl IdRef> = if n.last_is_imp then sg:mk_imp (n) else sg:mk_ref (n);

  n.ref = r;

  local dr::Decorated sg:Ref<IdDecl IdRef> = n.dec_graph.sg:dec_ref (r);
  
  n.ress := map ((\d::Decorated sg:Decl<IdDecl IdRef> -> (dr, d)), 
                 dr.sg:resolutions);
}

abstract production decl
d::IdDecl ::= id::String
{
  local parts::[String] = explode ("_", id);
  d.sg:name = head(parts);
  d.sg:index = head(tail(parts));
  d.sg:str_id = id;
}
