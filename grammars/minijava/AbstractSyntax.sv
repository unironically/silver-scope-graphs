grammar minijava;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Block;
nonterminal Extend;
nonterminal Implement;
nonterminal QidList;
nonterminal Qid;

-- Printing AST term
synthesized attribute pp::String occurs on Program, DeclList, Decl, Block, Extend, Implement, QidList, Qid;

------------------------------------------------------------
---- Program
------------------------------------------------------------

abstract production prog
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = "decllist_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_class
top::Decl ::= id::ID_t extend::Extend implement::Implement block::Block
{
  top.pp = "decl_class(" ++ id.lexeme ++ ", " ++ extend.pp ++ ", " ++ implement.pp ++ ", " ++ block.pp ++ ")";
}

------------------------------------------------------------
---- Block
------------------------------------------------------------

abstract production block
top::Block ::= list::DeclList
{
  top.pp = "block(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

abstract production extendlist_list
top::Extend ::= list::QidList
{
  top.pp = "extendlist_list(" ++ list.pp ++ ")";
}

abstract production extendlist_nothing
top::Extend ::=
{
  top.pp = "extendlist_nothing()";
}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

abstract production implementlist_list
top::Implement ::= list::QidList
{
  top.pp = "implementlist_list(" ++ list.pp ++ ")";
}

abstract production implementlist_nothing
top::Implement ::=
{
  top.pp = "implementlist_nothing()";
}

------------------------------------------------------------
---- Qid list
------------------------------------------------------------

abstract production qidlist_list
top::QidList ::= qid::Qid list::QidList
{
  top.pp = "qidlist_list(" ++ qid.pp ++ ", " ++ list.pp ++ ")";
}

abstract production qidlist_single
top::QidList ::= qid::Qid
{
  top.pp = "qidlist_single(" ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Qid
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "qid_dot(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
}