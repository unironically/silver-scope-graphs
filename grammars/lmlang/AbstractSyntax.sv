grammar lmlang;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;
nonterminal IdDcl;
nonterminal IdRef;

-- Attributes used in printing an AST
synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar, IdDcl, IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  -- ast printing
  top.pp = "prog(" ++ list.pp ++ ")";
}


------------------------------------------------------------
---- sg:Decl lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  -- ast printing
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- sg:Decls
------------------------------------------------------------

abstract production decl_module
top::Decl ::= decl::IdDcl list::DeclList
{
  -- ast printing
  top.pp = "decl_module("++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";
}

abstract production decl_def
top::Decl ::= decl::IdDcl exp::Exp
{
  -- ast printing
  top.pp = "decl_def(" ++ decl.pp ++ "," ++ exp.pp ++ ")";
}

abstract production decl_exp
top::Decl ::= exp::Exp
{
  -- ast printing
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  -- ast printing
  top.pp = "exp_let(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_seq
top::BindListSeq ::= decl::IdDcl exp::Exp list::BindListSeq
{
  -- ast printing
  top.pp = "bindlist_list_seq(" ++ decl.pp ++ "," ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  -- ast printing
  top.pp = "bindlist_nothing_seq()";
}

------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  -- ast printing
  top.pp = "exp_letrec(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  -- ast printing
  top.pp = "bindlist_list_rec(" ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  -- ast printing
  top.pp = "bindlist_nothing_rec()";
}


------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  -- ast printing
  top.pp = "exp_letpar(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{
  -- ast printing
  top.pp = "bindlist_list_par(" ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  -- ast printing
  top.pp = "bindlist_nothing_par()";
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= decl::IdDcl exp::Exp
{
  -- ast printing
  top.pp = "exp_funfix(" ++ decl.pp ++ "," ++ exp.pp ++ ")";
}

abstract production exp_add
top::Exp ::= left::Exp right::Exp
{
  -- ast printing
  top.pp = "add(" ++ left.pp ++ "," ++ right.pp ++ ")";
}

abstract production exp_app
top::Exp ::= left::Exp right::Exp
{
  -- ast printing
  top.pp = "app(" ++ left.pp ++ "," ++ right.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= ref::IdRef qid::Qid
{
  -- ast printing
  top.pp = "qid_list(" ++ ref.pp ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= ref::IdRef
{
  -- ast printing
  top.pp = "qid_single(" ++ ref.pp ++ ")";
}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

abstract production decl
top::IdDcl ::= id::ID_t
{
  -- ast printing
  top.pp = "decl(" ++ id.lexeme ++ ")";
}

abstract production ref
top::IdRef ::= id::ID_t
{
  -- ast printing
  top.pp = "ref(" ++ id.lexeme ++ ")";
}