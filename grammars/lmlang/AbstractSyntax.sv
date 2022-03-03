grammar lmlang;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindList;
nonterminal Bind;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, BindList, Bind;

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
}

abstract production decllist_single
top::DeclList ::= decl::Decl
{
  top.pp = "decllist_single(" ++ decl.pp ++ ")";
}

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = "decl_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
}

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  top.pp = "module(" ++ id.lexeme ++ ", " ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  top.pp = "import(" ++ qid.pp ++ ")";
}

abstract production decl_define
top::Decl ::= id::ID_t exp::Exp
{
  top.pp = "define(" ++ id.lexeme ++ " = " ++ exp.pp ++ ")";
}

-- Not included in the grammar given in the publication - but seems necessary for the examples given.
abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
}

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "qid_list(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

abstract production bindlist_nothing
top::BindList ::=
{
  top.pp = ".";
}

abstract production bindlist_list
top::BindList ::= id::ID_t exp::Exp list::BindList
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "plus(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "apply(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = "exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_fun
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = "fun(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_let
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "exp_let(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_letrec
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "exp_letrec(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_letpar
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "exp_letpar(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}
