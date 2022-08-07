grammar minijava;

synthesized attribute ast<a>::a;

nonterminal Program_c with ast<Program>;
nonterminal DeclList_c with ast<DeclList>;
nonterminal Decl_c with ast<Decl>;
nonterminal Block_c with ast<Block>;
nonterminal Extend_c with ast<Extend>;
nonterminal Implement_c with ast<Implement>;
nonterminal QidList_c with ast<QidList>;
nonterminal Qid_c with ast<Qid>;
nonterminal Expression_c with ast<Expression>;
nonterminal Type_c with ast<Type>;
nonterminal IdDcl_c with ast<IdDcl>;
nonterminal IdRef_c with ast<IdRef>;

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
top::Decl_c ::= Class_t id::IdDcl_c extend::Extend_c implement::Implement_c block::Block_c
{
  top.ast = decl_class(id.ast, extend.ast, implement.ast, block.ast);
}

concrete production decl_vardecl_c
top::Decl_c ::= type::Type_c id::IdDcl_c
{
  top.ast = decl_vardecl(type.ast, id.ast);
}

concrete production decl_expr_c
top::Decl_c ::= expr::Expression_c
{
  top.ast = decl_expr(expr.ast);
}

concrete production decl_method_c
top::Decl_c ::= type::Type_c id::IdDcl_c LParen_t RParen_t block::Block_c
{
  top.ast = decl_method(type.ast, id.ast, block.ast);
}


------------------------------------------------------------
---- Block
------------------------------------------------------------

concrete production block_c
top::Block_c ::= LCurly_t list::DeclList_c RCurly_t
{
  top.ast = block(list.ast);
}

------------------------------------------------------------
---- Expression
------------------------------------------------------------

concrete production expr_qid_c
top::Expression_c ::= qid::Qid_c
{
  top.ast = expr_qid(qid.ast);
}

------------------------------------------------------------
---- Types
------------------------------------------------------------

concrete production type_int_c
top::Type_c ::= IntType_t
{
  top.ast = type_int();
}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

concrete production extendlist_list_c
top::Extend_c ::= Extends_t list::QidList_c
{
  top.ast = extendlist_list(list.ast);
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
top::Implement_c ::= Implements_t list::QidList_c
{
  top.ast = implementlist_list(list.ast);
}

concrete productionimplementlist_nothing_c
top::Implement_c ::=
{
  top.ast = implementlist_nothing();
}

------------------------------------------------------------
---- Qid list
------------------------------------------------------------

concrete production qidlist_list_c
top::QidList_c ::= qid::Qid_c Comma_t list::QidList_c
{
  top.ast = qidlist_list(qid.ast, list.ast);
}

concrete production qidlist_single_c
top::QidList_c ::= qid::Qid_c
{
  top.ast = qidlist_single(qid.ast);
}

------------------------------------------------------------
---- Qid
------------------------------------------------------------

concrete production qid_dot_c
top::Qid_c ::= id::IdRef_c Dot_t qid::Qid_c
{
  top.ast = qid_dot(id.ast, qid.ast);
}

concrete production qid_single_c
top::Qid_c ::= id::IdRef_c
{
  top.ast = qid_single(id.ast);
}

------------------------------------------------------------
---- IdRef / IdDecl
------------------------------------------------------------

concrete production idref_c
top::IdRef_c ::= id::ID_t
{
  top.ast = idref(id);
}

concrete production iddcl_c
top::IdDcl_c ::= id::ID_t
{
  top.ast = iddcl(id);
}