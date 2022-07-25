grammar minijava;

synthesized attribute ast<a>::a;

nonterminal Program_c with ast<Program>;
nonterminal DeclList_c with ast<DeclList>;
nonterminal Decl_c with ast<Decl>;
nonterminal Block_c with ast<Block>;
nonterminal Extend_c with ast<Extend>;
nonterminal Implement_c with ast<Implement>;
nonterminal Qid_c with ast<Qid>;

------------------------------------------------------------
---- Program
------------------------------------------------------------

concrete production program_c
top::Program_c ::= list::DeclList_c
{
  top.ast = prog(list.ast);
}

------------------------------------------------------------
---- Declaration Lists
------------------------------------------------------------

concrete production decllist_list_c
top::DeclList_c ::= decl::Decl_c list::DeclList_c
{
  top.ast = decllist_list(decl.ast, list.ast);
}

concrete production decllist_nothing_c
top::DeclList_c ::=
{
  top.ast = decllist_nothing();
}

------------------------------------------------------------
---- Declarations
------------------------------------------------------------

concrete production decl_class_c
top::Decl_c ::= Class_t id::ID_t extend::Extend_c implement::Implement_c block::Block_c
{
  top.ast = decl_class(id, extend.ast, implement.ast, block.ast);
}

------------------------------------------------------------
---- Block
------------------------------------------------------------

concrete production block_c
top::Block_c ::= LCurly_t RCurly_t
{
  top.ast = block();
}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

concrete production extendlist_list_c
top::Extend_c ::= Extends_t qid::Qid_c
{
  top.ast = extendlist_list(qid.ast);
}

concrete production extendlist_nothing_c
top::Extend_c ::=
{
  top.ast = extendlist_nothing();
}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

concrete production implementlist_list_c
top::Implement_c ::= Implements_t qid::Qid_c
{
  top.ast = implementlist_list(qid.ast);
}

concrete productionimplementlist_nothing_c
top::Implement_c ::=
{
  top.ast = implementlist_nothing();
}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

concrete production qid_list_c
top::Qid_c ::= id::ID_t Dot_t qid::Qid_c
{
  top.ast = qid_list(id, qid.ast);
}

concrete production qid_single_c
top::Qid_c ::= id::ID_t
{
  top.ast = qid_single(id);
}