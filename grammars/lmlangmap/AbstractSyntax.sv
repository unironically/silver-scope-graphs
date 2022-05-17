grammar lmlangmap;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq;

inherited attribute inh_scope::Scope<Decorated Exp> occurs on DeclList, Decl, Qid, Exp, BindListSeq;

synthesized attribute syn_scope::Scope<Decorated Exp> occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq;
synthesized attribute ret_scope::Scope<Decorated Exp> occurs on BindListSeq;

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(nothing(), [], [], []);
  list.inh_scope = init_scope;
  top.syn_scope = list.syn_scope;
}



abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = "decl_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
  decl.inh_scope = top.inh_scope;
  list.inh_scope = decl.syn_scope;
  top.syn_scope = list.syn_scope;
}

abstract production decllist_nothing
top::DeclList ::=
{
  top.pp = "decl_list()";
  top.syn_scope = top.inh_scope;
}



--------------------------------------------------------------------------------
--- (un)removing this for now to (not) comply with the grammar in a theory of name resolution
--------------------------------------------------------------------------------
abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
  exp.inh_scope = top.inh_scope;
  top.syn_scope = exp.syn_scope;
}



------------------------------------------------------------
---- Handling sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.pp = "let(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
  list.inh_scope = top.inh_scope;
  top.syn_scope = list.syn_scope;
  exp.inh_scope = list.ret_scope;
}



-- Defines the binding pattern for the sequential let feature
abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  top.pp = "bind_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  exp.inh_scope = top.inh_scope; -- Passing S to e in the grammar
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(just(exp.syn_scope), exp.syn_scope.declarations, exp.syn_scope.references, exp.syn_scope.imports);
  list.inh_scope = init_scope;
  top.syn_scope = exp.syn_scope; -- Returning the parent scope passed to exp, can only change in exp
  top.ret_scope = list.ret_scope; -- Returning the scope possibly created in sub binding list
}

abstract production bindlist_nothing
top::BindListSeq ::=
{
  top.pp = "bind_list()";
  top.syn_scope = top.inh_scope; -- Simply returning the unchanged parent scope, this won't be used as binding list cannot change parent scope unless has an exp
  top.ret_scope = top.inh_scope; -- No new scope was created, to the binding list above should synthesize its own new scope
}



------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "add(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = expLeft.syn_scope;
  top.syn_scope = expRight.syn_scope;
}



abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "apply(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = expLeft.syn_scope;
  top.syn_scope = expRight.syn_scope;
}



abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = "exp_qid(" ++ qid.pp ++ ")";
  qid.inh_scope = top.inh_scope;
  top.syn_scope = qid.syn_scope;
}



abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid(" ++ id.lexeme ++ ")";
  -- Have to create a new scope at this point so that we can add the reference to id  
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(par_scope.parent, par_scope.declarations, id.lexeme::par_scope.references, par_scope.imports);
  top.syn_scope = init_scope;
}