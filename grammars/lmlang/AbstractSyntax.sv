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
  top.pp = list.pp;
}

abstract production decllist_single
top::DeclList ::= decl::Decl
{
  top.pp = decl.pp;
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
top::Decl ::= bnd::Bind
{
  top.pp = "define(" ++ bnd.pp ++ ")";
}

-- Not included in the grammar given in the publication - but seems necessary for the examples given.
abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.pp = exp.pp;
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = id.lexeme;
}

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "Qid(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

abstract production bindlist_single
top::BindList ::= bnd::Bind
{
  top.pp = bnd.pp;
}

abstract production bindlist_list
top::BindList ::= bnd::Bind list::BindList
{
  top.pp = "bind_list(" ++ bnd.pp ++ ", " ++ list.pp ++ ")";
}

abstract production bnd
top::Bind ::= id::ID_t exp::Exp
{
  top.pp = "bind(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
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
  top.pp = qid.pp;
}

abstract production exp_fun
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = "fun(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_let
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "let(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_letrec
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "letrec(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_letpar
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "letpar(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = val.lexeme;
}
