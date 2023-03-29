grammar sg_cs;

imports scope_tree:ast as sg;

nonterminal Program;
nonterminal NodeList;
nonterminal Dcls;
nonterminal Refs;
nonterminal Dcl;
nonterminal Qid;
nonterminal IdDcl;
nonterminal IdRef;

{-====================-} 

synthesized attribute graph::sg:Graph<IdDcl IdRef> occurs on Program;

synthesized attribute decls::sg:Dcls<IdDcl IdRef> occurs on NodeList, Dcls;
synthesized attribute refs::sg:Refs<IdDcl IdRef> occurs on NodeList, Refs;
synthesized attribute children::sg:Scopes<IdDcl IdRef> occurs on NodeList;

inherited attribute last_is_imp::Boolean occurs on Qid, IdRef;
synthesized attribute ref::sg:Ref<IdDcl IdRef> occurs on Qid, IdRef;

monoid attribute ress::[(Decorated sg:Ref<IdDcl IdRef>, Decorated sg:Dcl<IdDcl IdRef>)] 
  occurs on Program, NodeList, Refs, Qid, IdRef;
propagate ress on Program, NodeList, Refs, Qid;

inherited attribute dec_graph::sg:Graph<IdDcl IdRef> 
  occurs on Program, NodeList, Refs, Qid, IdRef;
propagate dec_graph on NodeList, Refs, Qid; 

{- required by scope graph abstract syntax -}
attribute sg:str_id occurs on IdDcl, IdRef;
flowtype sg:str_id {} on IdDcl, IdRef;

attribute sg:name occurs on IdDcl, IdRef;
flowtype sg:name {} on IdDcl, IdRef;

attribute sg:index occurs on IdDcl, IdRef;
flowtype sg:index {} on IdDcl, IdRef;

{-====================-}

{- Program -}

abstract production program
p::Program ::= sl::NodeList
{
  local g::sg:Graph<IdDcl IdRef> = sg:mk_graph (s);
  local s::sg:Scope<IdDcl IdRef> = sg:mk_scope (sl.decls, sl.refs, sl.children);
  p.graph = g;
  sl.dec_graph = g;
}

{- Node List -}

abstract production nodelist_decls
sl::NodeList ::= dl::Dcls slt::NodeList
{
  sl.decls = sg:combine_decls (dl.decls, slt.decls);
  sl.refs = slt.refs;
  sl.children = slt.children;
}

abstract production decl_module
sl::NodeList ::= id::IdDcl sub::NodeList slt::NodeList
{
  local s::sg:Scope<IdDcl IdRef> = sg:mk_scope (sub.decls, sub.refs, sub.children);
  local d::sg:Dcl<IdDcl IdRef> = sg:mk_decl_assoc (id, s);
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
  local s::sg:Scope<IdDcl IdRef> = sg:mk_scope (sub.decls, sub.refs, sub.children);
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

{- Dcls -}

abstract production decls_comma
ds::Dcls ::= id::IdDcl dst::Dcls
{
  local d::sg:Dcl<IdDcl IdRef> = sg:mk_decl (id);
  ds.decls = sg:decl_cons (d, dst.decls);
}

abstract production decls_last
ds::Dcls ::= id::IdDcl
{
  local d::sg:Dcl<IdDcl IdRef> = sg:mk_decl (id);
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
  local s::sg:Scope<IdDcl IdRef> = sg:mk_scope_qid (qt.ref);
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


  local r::sg:Ref<IdDcl IdRef> = if n.last_is_imp then sg:mk_imp (n) else sg:mk_ref (n);

  n.ref = r;

  local dr::Decorated sg:Ref<IdDcl IdRef> = n.dec_graph.sg:dec_ref (r);
  
  n.ress := map ((\d::Decorated sg:Dcl<IdDcl IdRef> -> (dr, d)), 
                 dr.sg:resolutions);
}

abstract production decl
d::IdDcl ::= id::String
{
  local parts::[String] = explode ("_", id);
  d.sg:name = head(parts);
  d.sg:index = head(tail(parts));
  d.sg:str_id = id;
}
