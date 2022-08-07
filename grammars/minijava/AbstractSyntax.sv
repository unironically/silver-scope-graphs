grammar minijava;

imports scopegraph_kw as sg;


nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Block;
nonterminal Extend;
nonterminal Implement;
nonterminal QidList;
nonterminal Qid;
nonterminal Expression;
nonterminal Type;
nonterminal IdDcl;
nonterminal IdRef;

-- Printing AST term
synthesized attribute pp::String occurs on Program, DeclList, Decl, Block, Extend, Implement, 
  QidList, Qid, Expression, Type, IdDcl, IdRef;

------------------------------------------------------------
---- Program
------------------------------------------------------------

abstract production prog
top::Program ::= list::DeclList
{
  -- ast printing
  top.pp = "prog(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  -- ast printing
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_class
top::Decl ::= id::IdDcl extend::Extend implement::Implement block::Block
{
  -- ast printing
  top.pp = "decl_class(" ++ id.pp ++ ", " ++ extend.pp ++ ", " ++ implement.pp ++ ", " ++ block.pp ++ ")";
}

abstract production decl_vardecl
top::Decl ::= type::Type id::IdDcl
{
  -- ast printing
  top.pp = "decl_vardecl(" ++ type.pp ++ ", " ++ id.pp ++ ")";
}

abstract production decl_method
top::Decl ::= type::Type id::IdDcl block::Block
{
  -- ast printing
  top.pp = "decl_method(" ++ type.pp ++ ", " ++ id.pp ++ ", " ++ block.pp ++ ")";
}

abstract production decl_expr
top::Decl ::= expr::Expression
{
  -- ast printing
  top.pp = "decl_expr(" ++ expr.pp ++ ")";
}

------------------------------------------------------------
---- Block
------------------------------------------------------------

abstract production block
top::Block ::= list::DeclList
{
  -- ast printing
  top.pp = "block(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Expression
------------------------------------------------------------

abstract production expr_qid
top::Expression ::= qid::Qid
{
  -- ast printing
  top.pp = "expr_qid(" ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Types
------------------------------------------------------------

abstract production type_int
top::Type ::=
{
  -- ast printing
  top.pp = "type_int()";
}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

abstract production extendlist_list
top::Extend ::= list::QidList
{
  -- ast printing
  top.pp = "extendlist_list(" ++ list.pp ++ ")";
}

abstract production extendlist_nothing
top::Extend ::=
{
  -- ast printing
  top.pp = "extendlist_nothing()";
}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

abstract production implementlist_list
top::Implement ::= list::QidList
{
  -- ast printing
  top.pp = "implementlist_list(" ++ list.pp ++ ")";
}

abstract production implementlist_nothing
top::Implement ::=
{
  -- ast printing
  top.pp = "implementlist_nothing()";
}

------------------------------------------------------------
---- Qid list
------------------------------------------------------------

abstract production qidlist_list
top::QidList ::= qid::Qid list::QidList
{
  -- ast printing
  top.pp = "qidlist_list(" ++ qid.pp ++ ", " ++ list.pp ++ ")";
}

abstract production qidlist_single
top::QidList ::= qid::Qid
{
  -- ast printing
  top.pp = "qidlist_single(" ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Qid
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= id::IdRef qid::Qid
{
  -- ast printing
  top.pp = "qid_list(" ++ id.pp ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= id::IdRef
{
  -- ast printing
  top.pp = "qid_single(" ++ id.pp ++ ")";

}

------------------------------------------------------------
---- IdRef / IdDecl
------------------------------------------------------------

abstract production idref
top::IdRef ::= id::ID_t
{
  -- ast printing
  top.pp = "idref(" ++ id.lexeme ++ ")";
}

abstract production iddcl
top::IdDcl ::= id::ID_t
{
  -- ast printing
  top.pp = "iddcl(" ++ id.lexeme ++ ")";
}