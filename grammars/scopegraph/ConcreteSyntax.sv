grammar scopegraph;

synthesized attribute scope_c :: Scope;
synthesized attribute decl_c :: Decl;
synthesized attribute decls_c :: Decls;
synthesized attribute ref_c :: Ref;
synthesized attribute refs_c :: Refs;
synthesized attribute children_c :: [Scope];

inherited attribute parent_c::Scope occurs on 
  NodeList_c, Decls_c, Decl_c, Refs_c, Ref_c;
propagate parent_c on NodeList_c, Decls_c, Refs_c;

nonterminal Program_c with scope_c;
nonterminal NodeList_c with decls_c, refs_c, children_c;
nonterminal Decls_c with decls_c;
nonterminal Decl_c with decl_c;
nonterminal Refs_c with refs_c;
nonterminal Ref_c with ref_c;

{- Program -}

concrete production program_c
p::Program_c ::= sl::NodeList_c
{
  p.scope_c = mk_scope (sl.decls_c, sl.refs_c, sl.children_c);
}

{- Node List -}

concrete production scopelist_decl_c
sl::NodeList_c ::= d::Decl_c slt::NodeList_c
{
  sl.decls_c = decl_cons (d.decl_c, slt.decls_c);
  sl.refs_c = slt.refs_c;
  sl.children_c = slt.children_c;
}

concrete production scopelist_ref_c
sl::NodeList_c ::= r::Ref_c slt::NodeList_c
{
  sl.decls_c = slt.decls_c;
  sl.refs_c = ref_cons(r.ref_c, slt.refs_c);
  sl.children_c = slt.children_c;
}

concrete production scopelist_nothing_c
sl::NodeList_c ::= 
{
  sl.decls_c = decl_nil ();
  sl.refs_c = ref_nil ();
  sl.children_c = [];
}

{- Decl -}

concrete production decl_single_c
d::Decl_c ::= Decl_t id::ID_t
{
  d.decl_c = mk_decl (id.lexeme, nothing());
}

{- Ref -}

concrete production ref_single_c
r::Ref_c ::= Ref_t id::ID_t
{
  r.ref_c = mk_ref (id.lexeme);
}

{- Decls -}

concrete production decl_cons_c
ds::Decls_c ::= d::Decl_c dl::Decls_c
{
  ds.decls_c = decl_cons(d.decl_c, dl.decls_c);
}

concrete production decl_nil_c
ds::Decls_c ::=
{
  ds.decls_c = decl_nil ();
}

{- Refs -}

concrete production ref_cons_c
rs::Refs_c ::= r::Ref_c rl::Refs_c
{
  rs.refs_c = ref_cons (r.ref_c, rl.refs_c);
}

concrete production ref_nil_c
rs::Refs_c ::=
{
  rs.refs_c = ref_nil ();
}