grammar scopegraph;

synthesized attribute graph_c :: Graph;
synthesized attribute scope_c :: Scope;
synthesized attribute decl_c :: Decl;
synthesized attribute decls_c :: Decls;
synthesized attribute ref_c :: Ref;
synthesized attribute refs_c :: Refs;
synthesized attribute imp_c :: Ref;
synthesized attribute imps_c :: Imps;
synthesized attribute children_c :: Scopes;

synthesized attribute root_scopes_c::Scopes occurs on
  NodeList_c, Decl_c, Qid_c, Refs_c;

inherited attribute parent_c :: Scope occurs on 
  NodeList_c, Decl_c, Decls_c, Refs_c, Qid_c;

nonterminal Program_c with graph_c;
nonterminal NodeList_c with decls_c, refs_c, imps_c, children_c;
nonterminal Decls_c with decls_c;
nonterminal Refs_c with refs_c;
nonterminal Decl_c with decl_c,children_c;
nonterminal Qid_c with ref_c, imp_c, children_c;

{- Program -}

concrete production program_c
p::Program_c ::= sl::NodeList_c
{
  local new_scope :: Scope = 
    mk_scope (sl.decls_c, sl.refs_c, sl.imps_c, sl.children_c);

  local new_graph :: Graph = mk_graph (scope_cons (new_scope, sl.root_scopes_c));
  p.graph_c = new_graph;
  
  sl.parent_c = new_scope;
}

{- Node List -}

concrete production nodelist_decls_c
sl::NodeList_c ::= Decls_t dl::Decls_c slt::NodeList_c
{
  slt.parent_c = sl.parent_c;
  dl.parent_c = sl.parent_c;
  sl.decls_c = combine_decls(dl.decls_c, slt.decls_c);
  sl.refs_c = slt.refs_c;
  sl.imps_c = slt.imps_c;
  sl.children_c = slt.children_c;
  sl.root_scopes_c = slt.root_scopes_c;
}

concrete production decl_module_c
sl::NodeList_c ::= Module_t id::ID_t LBrace_t sub::NodeList_c RBrace_t slt::NodeList_c
{
  local new_scope :: Scope = mk_scope_assoc (sub.decls_c, sub.refs_c, sub.imps_c, sub.children_c, new_decl);
  local new_decl :: Decl = mk_decl_assoc (id.lexeme, new_scope);

  sl.decls_c = decl_cons (new_decl, slt.decls_c);
  sl.refs_c = slt.refs_c;
  sl.imps_c = slt.imps_c;
  sl.children_c = scope_cons (new_scope, slt.children_c);
  sl.root_scopes_c = combine_scopes (sub.root_scopes_c, slt.root_scopes_c);

  sub.parent_c = new_scope;
  slt.parent_c = sl.parent_c;
}

concrete production nodelist_refs_c
sl::NodeList_c ::= Refs_t rl::Refs_c slt::NodeList_c
{
  slt.parent_c = sl.parent_c;
  rl.parent_c = sl.parent_c;
  sl.decls_c = slt.decls_c;
  sl.refs_c = combine_refs (rl.refs_c, slt.refs_c);
  sl.imps_c = slt.imps_c;
  sl.children_c = slt.children_c;
  sl.root_scopes_c = combine_scopes (rl.root_scopes_c, slt.root_scopes_c);
}

concrete production nodelist_import_c
sl::NodeList_c ::= Import_t qid::Qid_c slt::NodeList_c
{
  propagate parent_c;
  sl.decls_c = slt.decls_c;
  sl.refs_c = ref_cons (qid.ref_c, slt.refs_c);
  sl.imps_c = imp_cons (qid.imp_c, slt.imps_c);
  sl.children_c = combine_scopes(qid.children_c, slt.children_c);
  sl.root_scopes_c = combine_scopes(qid.root_scopes_c, slt.root_scopes_c);
}

concrete production nodelist_subscope_c
sl::NodeList_c ::= LBrace_t sub::NodeList_c RBrace_t slt::NodeList_c
{
  local new_scope :: Scope = 
    mk_scope (sub.decls_c, sub.refs_c, sub.imps_c, sub.children_c);

  sub.parent_c = new_scope;
  slt.parent_c = sl.parent_c;

  sl.decls_c = decl_nil ();
  sl.refs_c = ref_nil ();
  sl.imps_c = imp_nil ();
  sl.children_c = scope_cons(new_scope, scope_nil());
  sl.root_scopes_c = combine_scopes (sub.root_scopes_c, slt.root_scopes_c);
}

concrete production nodelist_nothing_c
sl::NodeList_c ::= 
{
  sl.decls_c = decl_nil ();
  sl.refs_c = ref_nil ();
  sl.imps_c = imp_nil ();
  sl.children_c = scope_nil ();
  sl.root_scopes_c = scope_nil ();
}

{- Decls -}

concrete production decls_comma_c
ds::Decls_c ::= id::ID_t Comma_t dst::Decls_c
{ 
  propagate parent_c;
  local new_decl :: Decl = mk_decl (id.lexeme);
  ds.decls_c = decl_cons (new_decl, dst.decls_c);
}

concrete production decls_last_c
ds::Decls_c ::= id::ID_t
{
  local new_decl :: Decl = mk_decl (id.lexeme);
  ds.decls_c = decl_cons (new_decl, decl_nil ());
}

{- Refs -}

concrete production refs_comma_c
rs::Refs_c ::= qid::Qid_c Comma_t rst::Refs_c
{ 
  propagate parent_c;
  rs.root_scopes_c = qid.root_scopes_c;
  rs.refs_c = ref_cons (qid.ref_c, rst.refs_c);
}

concrete production refs_last_c
rs::Refs_c ::= qid::Qid_c
{
  propagate parent_c;
  rs.root_scopes_c = qid.root_scopes_c;
  rs.refs_c = ref_cons (qid.ref_c, ref_nil ());
}

{- Qid -}

concrete production qid_dot_c
q::Qid_c ::= id::ID_t Dot_t qt::Qid_c
{
  local new_ref_dot::Ref = mk_ref (id.lexeme);

  local new_scope::Scope = mk_scope (
    decl_nil (), 
    ref_cons (qt.ref_c, ref_nil ()), 
    imp_cons (new_ref_dot, imp_nil ()), 
    scope_nil());

  q.ref_c = new_ref_dot;
  q.imp_c = qt.imp_c;
  q.children_c = scope_cons(new_scope, qt.children_c);
  q.root_scopes_c = scope_cons (new_scope, qt.root_scopes_c);

  qt.parent_c = new_scope;
}

concrete production qid_single_c
q::Qid_c ::= id::ID_t
{
  local new_ref::Ref = mk_ref (id.lexeme);

  q.ref_c = new_ref;
  q.imp_c = new_ref;
  q.children_c = scope_nil ();
  q.root_scopes_c = scope_nil ();
}
