grammar lmlangmap;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;

synthesized attribute free_vars_syn::[String] occurs on Exp, Qid, BindListSeq, BindListRec, BindListPar;

inherited attribute free_vars_inh::[String] occurs on BindListSeq, BindListRec, BindListPar;

synthesized attribute declarations_syn::[(String, Maybe<Scope<Decorated Exp>>)] occurs on BindListRec, BindListPar;

inherited attribute inh_scope_second::Scope<Decorated Exp> occurs on BindListPar;

inherited attribute inh_scope::Scope<Decorated Exp> occurs on DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
synthesized attribute cur_scope::Scope<Decorated Exp> occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(nothing(), [], []);
  list.inh_scope = init_scope;
  top.cur_scope = list.cur_scope;
}

abstract production decllist_single
top::DeclList ::= decl::Decl
{
  top.pp = "decllist_single(" ++ decl.pp ++ ")";
  decl.inh_scope = top.inh_scope;
  top.cur_scope = decl.cur_scope;
}

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = "decl_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
  decl.inh_scope = top.inh_scope;
  list.inh_scope = decl.cur_scope;
  top.cur_scope = list.cur_scope;
}

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  top.pp = "module(" ++ id.lexeme ++ ", " ++ list.pp ++ ")";
  
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  -- Creating the scope for this module:
  list.inh_scope = cons_scope(just(par_scope), [], []);
  -- Updating the current scope with the module name reference (including its associated scope):
  top.cur_scope = cons_scope(par_scope.parent, (id.lexeme, just(list.cur_scope))::par_scope.declarations, par_scope.references);
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
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  local attribute upd_scope::Scope<Decorated Exp> = cons_scope(par_scope.parent, (id.lexeme, nothing())::par_scope.declarations, par_scope.references);
  exp.inh_scope = upd_scope;
  top.cur_scope = exp.cur_scope;
}


--------------------------------------------------------------------------------
--- removing this for now to comply with the grammar in a theory of name resolution
--------------------------------------------------------------------------------
--abstract production decl_exp
--top::Decl ::= exp::Exp
--{
--  top.pp = "decl_exp(" ++ exp.pp ++ ")";
--  exp.inh_scope = top.inh_scope;
--  top.cur_scope = exp.cur_scope;
--}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
  top.free_vars_syn = [id.lexeme];
}

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "qid_list(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Handling sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  local attribute ret_scope::Scope<Decorated Exp> = list.cur_scope;

  exp.inh_scope = ret_scope;

  list.inh_scope = top.cur_scope;
  list.free_vars_inh = exp.free_vars_syn;

  -- Remaking the "parent" scope of this let expr based on the free vars of the binding list
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  top.cur_scope = cons_scope(par_scope.parent, par_scope.declarations, union(par_scope.references, list.free_vars_syn)); 

  top.pp = "exp_let(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

-- Defines the binding pattern for the sequential let feature
abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  -- References are those free vars found in the next binding's expr
  local attribute new_scope::Scope<Decorated Exp> = cons_scope(just(top.inh_scope), [(id.lexeme, nothing())], list.free_vars_syn);

  exp.inh_scope = top.inh_scope;

  list.inh_scope = new_scope;
  list.free_vars_inh = top.free_vars_inh;

  -- Free variables found in the expr that id is being bound to - these are attached to the parent scope of this let expr
  top.free_vars_syn = union(exp.free_vars_syn, list.free_vars_syn);
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
}

abstract production bindlist_final_seq
top::BindListSeq ::= id::ID_t exp::Exp
{
  -- References are all those free vars in the RHS of the lexically-enclosing let expr
  local attribute new_scope::Scope<Decorated Exp> = cons_scope(just(top.inh_scope), [(id.lexeme, nothing())], top.free_vars_inh);

  exp.inh_scope = top.inh_scope;

  -- Free variables found in the expr that id is being bound to - these will be attached to the parent scope of this let expr
  top.free_vars_syn = exp.free_vars_syn;
  top.cur_scope = new_scope;
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ")";
}

------------------------------------------------------------
---- Handling recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  local attribute new_scope::Scope<Decorated Exp> = cons_scope(
    just(top.inh_scope), 
    list.declarations_syn, 
    union(list.free_vars_syn, exp.free_vars_syn)
  );

  exp.inh_scope = new_scope;

  -- Remaking the "parent" scope of this let expr based on the free vars of the binding list
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  top.cur_scope = top.inh_scope; 
  top.pp = "exp_letrec(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

-- Defines the binding pattern for the recursive let feature
abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  top.declarations_syn = (id.lexeme, nothing())::list.declarations_syn;
  exp.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;
  top.free_vars_syn = union(exp.free_vars_syn, list.free_vars_syn);
}

abstract production bindlist_final_rec
top::BindListRec ::= id::ID_t exp::Exp
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ")";
  top.declarations_syn = [(id.lexeme, nothing())];
  top.free_vars_syn = exp.free_vars_syn;
}

------------------------------------------------------------
---- Handling parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  exp.inh_scope = new_scope;

  -- Remaking the "parent" scope of this let expr based on the free vars of the binding list
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  top.cur_scope = cons_scope(par_scope.parent, par_scope.declarations, union(par_scope.references, list.free_vars_syn)); 

  local attribute new_scope::Scope<Decorated Exp> = cons_scope(just(top.inh_scope), list.declarations_syn, exp.free_vars_syn);
  top.cur_scope = new_scope;
  top.pp = "exp_letpar(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

-- Defines the binding pattern for the parallel let feature
abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  top.declarations_syn = (id.lexeme, nothing())::list.declarations_syn;
  exp.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;
  list.inh_scope_second = top.inh_scope_second;
  top.free_vars_syn = union(exp.free_vars_syn, list.free_vars_syn);
}

abstract production bindlist_final_par
top::BindListPar ::= id::ID_t exp::Exp
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ")";
  top.declarations_syn = [(id.lexeme, nothing())];
  top.free_vars_syn = exp.free_vars_syn;
}

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = top.inh_scope;

  -- Merging the resulting "parent" scopes from both the left and right child
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  local attribute left_scope::Scope<Decorated Exp> = expLeft.cur_scope;
  local attribute right_scope::Scope<Decorated Exp> = expRight.cur_scope;
  top.cur_scope = cons_scope(
    par_scope.parent, 
    left_scope.declarations ++ right_scope.declarations, 
    left_scope.references ++ right_scope.references
  );

  top.pp = "plus(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = top.inh_scope;

  -- Merging the resulting "parent" scopes from both the left and right child
  local attribute par_scope::Scope<Decorated Exp> = top.inh_scope;
  local attribute left_scope::Scope<Decorated Exp> = expLeft.cur_scope;
  local attribute right_scope::Scope<Decorated Exp> = expRight.cur_scope;
  top.cur_scope = cons_scope(
    par_scope.parent, 
    left_scope.declarations ++ right_scope.declarations, 
    left_scope.references ++ right_scope.references
  );

  top.pp = "apply(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = "exp_qid(" ++ qid.pp ++ ")";
  qid.inh_scope = top.inh_scope;
  top.free_vars_syn = qid.free_vars_syn;
}

abstract production exp_fun
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = "fun(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
}


abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}
