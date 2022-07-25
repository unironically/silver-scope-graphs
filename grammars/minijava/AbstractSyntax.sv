grammar minijava;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Block;
nonterminal Extend;
nonterminal Implement;
nonterminal Qid;

------------------------------------------------------------
---- Program
------------------------------------------------------------

abstract production prog
top::Program ::= list::DeclList
{

}

------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{

}

abstract production decllist_nothing
top::DeclList ::=
{

}

------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_class
top::Decl ::= id::ID_t extend::Extend implement::Implement block::Block
{

}

------------------------------------------------------------
---- Block
------------------------------------------------------------

abstract production block
top::Block ::=
{

}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

abstract production extendlist_list
top::Extend ::= qid::Qid
{

}

abstract production extendlist_nothing
top::Extend ::=
{

}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

abstract production implementlist_list
top::Implement ::= qid::Qid
{

}

abstract production implementlist_nothing
top::Implement ::=
{

}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{

}

abstract production qid_single
top::Qid ::= id::ID_t
{

}