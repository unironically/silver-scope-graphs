grammar scopegraph;

synthesized attribute scope_c :: Decorated Scope;
synthesized attribute decl_c :: Decorated Decl;
synthesized attribute decls_c :: Decls;
synthesized attribute ref_c :: Decorated Ref;
synthesized attribute refs_c :: Refs;
synthesized attribute imp_c :: Decorated Ref;
synthesized attribute imps_c :: Imps;
synthesized attribute children_c :: [Decorated Scope];

inherited attribute parent_c :: Decorated Scope occurs on 
  NodeList_c, Decl_c, Qid_c;
propagate parent_c on NodeList_c;

nonterminal Program_c with scope_c;
nonterminal NodeList_c with decls_c, refs_c, imps_c, children_c;
nonterminal Decl_c with decl_c, children_c;
nonterminal Qid_c with ref_c, imp_c, children_c;

{- Program -}

concrete production program_c
p::Program_c ::= sl::NodeList_c
{
  local new_scope :: Scope = 
    mk_scope (sl.decls_c, sl.refs_c, sl.imps_c, sl.children_c);
  new_scope.scope_parent = nothing();

  p.scope_c = new_scope;
  sl.parent_c = new_scope;
}

{- Node List -}

concrete production scopelist_decl_c
sl::NodeList_c ::= d::Decl_c slt::NodeList_c
{
  sl.decls_c = decl_cons (d.decl_c, slt.decls_c);
  sl.refs_c = slt.refs_c;
  sl.imps_c = slt.imps_c;
  sl.children_c = d.children_c ++ slt.children_c;
}

concrete production scopelist_ref_c
sl::NodeList_c ::= Ref_t qid::Qid_c slt::NodeList_c
{
  sl.decls_c = slt.decls_c;
  sl.refs_c = ref_cons (qid.ref_c, slt.refs_c);
  sl.imps_c = slt.imps_c;
  sl.children_c = qid.children_c ++ slt.children_c;
}

concrete production scopelist_import_c
sl::NodeList_c ::= Import_t qid::Qid_c slt::NodeList_c
{
  sl.decls_c = slt.decls_c;
  sl.refs_c = ref_cons (qid.ref_c, slt.refs_c);
  sl.imps_c = imp_cons (qid.imp_c, slt.imps_c);
  sl.children_c = qid.children_c ++ slt.children_c;
}

concrete production scopelist_nothing_c
sl::NodeList_c ::= 
{
  sl.decls_c = decl_nil ();
  sl.refs_c = ref_nil ();
  sl.imps_c = imp_nil ();
  sl.children_c = [];
}

{- Decl -}

concrete production decl_single_c
d::Decl_c ::= Decl_t id::ID_t
{
  local new_decl :: Decl = mk_decl (id.lexeme, nothing());
  new_decl.parent = d.parent_c;

  d.decl_c = new_decl;
  d.children_c = [];
}

concrete production decl_module_c
d::Decl_c ::= Module_t id::ID_t LBrace_t sl::NodeList_c RBrace_t
{
  local new_scope :: Scope = mk_scope (sl.decls_c, sl.refs_c, sl.imps_c, sl.children_c);
  new_scope.scope_parent = just(d.parent_c);

  local new_decl :: Decl = mk_decl (id.lexeme, just(new_scope));
  new_decl.parent = d.parent_c;

  d.decl_c = new_decl;
  d.children_c = new_scope :: sl.children_c;

  sl.parent_c = new_scope;
}

{- Qid -}

concrete production qid_dot_c
q::Qid_c ::= id::ID_t Dot_t qt::Qid_c
{
  local new_ref::Ref = mk_ref (id.lexeme);
  new_ref.parent = q.parent_c;

  local new_scope::Scope = mk_scope (
    decl_nil (), 
    ref_cons (qt.ref_c, ref_nil ()), 
    imp_cons (new_ref, imp_nil ()), 
    qt.children_c);
  new_scope.scope_parent = nothing ();

  q.ref_c = new_ref;
  q.imp_c = qt.imp_c;
  q.children_c = new_scope :: qt.children_c;

  qt.parent_c = new_scope;
}

concrete production qid_single_c
q::Qid_c ::= id::ID_t
{
  local new_ref::Ref = mk_ref (id.lexeme);
  new_ref.parent = q.parent_c;

  q.ref_c = new_ref;
  q.imp_c = new_ref;
  q.children_c = [];
}