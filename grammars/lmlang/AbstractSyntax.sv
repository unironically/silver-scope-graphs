grammar lmlang;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;

inherited attribute env::[(String, Decorated Exp)] occurs on DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
synthesized attribute defs::[(String, Decorated Exp)] occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
  list.env = [];
  top.defs = list.defs;
}

abstract production decllist_single
top::DeclList ::= decl::Decl
{
  top.pp = "decllist_single(" ++ decl.pp ++ ")";
  decl.env = top.env;
  top.defs = decl.defs;
}

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = "decl_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
  decl.env = top.env; -- declarations from decl not visible within list - check intended semantics
  list.env = top.env;
  top.defs = appendList(decl.defs, list.defs);
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
  exp.env = top.env;
  top.defs = [(id.lexeme, exp)];
}

-- Not included in the grammar given in the publication - but seems necessary for the examples given.
abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
  exp.env = top.env;
  top.defs = exp.defs;
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
  top.defs = [];
}

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "qid_list(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
  qid.env = top.env;
  top.defs = [];
}

-- Defines the binding pattern for the sequential let feature
abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  -- for sequential let ?
  exp.env = top.env;
  list.env = appendList([(id.lexeme, exp)], top.env);
  top.defs = appendList([(id.lexeme, exp)], list.defs);
}

-- Defines the binding pattern for the recursive let feature
abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  -- for recursive let ?
  exp.env = appendList(list.defs, top.env);
  list.env = appendList([(id.lexeme, exp)], appendList(list.defs, top.env));
  top.defs = appendList([(id.lexeme, exp)], list.defs);
}

-- Defines the binding pattern for the parallel let feature
abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListRec
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  -- for parallel let?
  exp.env = top.env;
  list.env = top.env;
  top.defs = appendList([(id.lexeme, exp)], list.defs);
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  top.pp = ".";
  top.defs = [];
}

abstract production bindlist_nothing_rec
top::BindListSeq ::=
{
  top.pp = ".";
  top.defs = [];
}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  top.pp = ".";
  top.defs = [];
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "plus(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
  expLeft.env = top.env;
  expRight.env = top.env;
  top.defs = appendList(expLeft.defs, expRight.defs);
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "apply(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
  expLeft.env = top.env;
  expRight.env = top.env;
  top.defs = appendList(expLeft.defs, expRight.defs);
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = "exp_qid(" ++ qid.pp ++ ")";
  qid.env = top.env;
  top.defs = [];
}

abstract production exp_fun
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = "fun(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
  exp.env = top.env;
  top.defs = [(id.lexeme, exp)];
}

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.pp = "exp_let(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
  list.env = top.env;
  exp.env = appendList(list.defs, top.env);
  top.defs = appendList(list.defs, exp.defs);
}

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  top.pp = "exp_letrec(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
  list.env = top.env;
  exp.env = top.env;
  top.defs = [];
}

--abstract production exp_letpar
--top::Exp ::= list::BindList exp::Exp
--{
--  top.pp = "exp_letpar(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
--  list.bindlist_mode = 3;
--  top.defs = [];
--}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
  top.defs = [];
}
