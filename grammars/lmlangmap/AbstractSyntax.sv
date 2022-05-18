grammar lmlangmap;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute tab_level::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
global tab_spacing :: String = "\t";

inherited attribute inh_scope::Scope<Decorated Exp> occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_two::Scope<Decorated Exp> occurs on BindListPar;

synthesized attribute syn_scope::Scope<Decorated Exp> occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
synthesized attribute syn_scope_two::Scope<Decorated Exp> occurs on BindListPar;
synthesized attribute ret_scope::Scope<Decorated Exp> occurs on BindListSeq;



------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "program(\n" ++ list.pp ++ "\n)";
  list.tab_level = tab_spacing;

  local attribute init_scope::Scope<Decorated Exp> = cons_scope(nothing(), [], [], []);
  list.inh_scope = init_scope;
  top.syn_scope = list.syn_scope;
}



------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = top.tab_level ++ "decl_list(\n" ++ decl.pp ++ ",\n" 
    ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  decl.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  decl.inh_scope = top.inh_scope;
  list.inh_scope = decl.syn_scope;
  top.syn_scope = list.syn_scope;
}

abstract production decllist_nothing
top::DeclList ::=
{
  top.pp = top.tab_level ++ "decl_list()";
  top.syn_scope = top.inh_scope;
}



------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_exp
-- (un)removing this for now to (not) comply with the grammar in a theory of name resolution
top::Decl ::= exp::Exp
{
  top.pp = top.tab_level ++ "decl_exp(\n" ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;

  exp.inh_scope = top.inh_scope;
  top.syn_scope = exp.syn_scope;
}

abstract production decl_def
top::Decl ::= id::ID_t exp::Exp
{
  top.pp = top.tab_level ++ "def(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n"
    ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(exp.syn_scope), 
    (id.lexeme, nothing())::exp.syn_scope.declarations, 
    exp.syn_scope.references, 
    exp.syn_scope.imports
  );
  exp.inh_scope = init_scope;
  top.syn_scope = exp.syn_scope;
}



------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.pp = top.tab_level ++ "let(\n" ++ list.pp ++ ",\n" ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  list.tab_level = tab_spacing ++ top.tab_level;
  exp.tab_level = tab_spacing ++ top.tab_level;

  list.inh_scope = top.inh_scope;
  top.syn_scope = list.syn_scope;
  exp.inh_scope = list.ret_scope;
}

-- Defines the binding pattern for the sequential let feature
abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  top.pp = top.tab_level ++ "bind_list(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n" 
    ++ exp.pp ++ ",\n" ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  exp.inh_scope = top.inh_scope; -- Passing S to e in the grammar
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(exp.syn_scope), 
    (id.lexeme, nothing())::exp.syn_scope.declarations, 
    exp.syn_scope.references, 
    exp.syn_scope.imports
  );
  list.inh_scope = init_scope;
  top.syn_scope = exp.syn_scope; -- Returning the parent scope passed to exp, can only change in exp
  top.ret_scope = list.ret_scope; -- Returning the scope possibly created in sub binding list
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  top.pp = top.tab_level ++ "bind_list()";

  top.syn_scope = top.inh_scope; -- Simply returning the unchanged parent scope, this won't be used as binding list cannot change parent scope unless has an exp
  top.ret_scope = top.inh_scope; -- No new scope was created, to the binding list above should synthesize its own new scope
}



------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  top.pp = top.tab_level ++ "exp_letrec(\n" ++ list.pp ++ ",\n" 
    ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  list.tab_level = tab_spacing ++ top.tab_level;
  exp.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(top.inh_scope), 
    top.inh_scope.declarations, 
    top.inh_scope.references, 
    top.inh_scope.imports
  );
  list.inh_scope = init_scope;
  exp.inh_scope = list.syn_scope;
  top.syn_scope = top.inh_scope; -- inherited (parent) scope is unchanged, since init_scope is used in sub bind list and exp
}

-- Defines the binding pattern for the recursive let feature
abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  top.pp = top.tab_level ++ "bindlist_list(\n" ++ top.tab_level ++ tab_spacing 
    ++ id.lexeme ++ " = " ++ exp.pp ++ ",\n" ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(top.inh_scope), 
    (id.lexeme, nothing())::top.inh_scope.declarations, 
    top.inh_scope.references, 
    top.inh_scope.imports
  ); -- change made to parent scope, must become syn_scope (after possible changes in exp and sub bind list)
  exp.inh_scope = init_scope;
  list.inh_scope = exp.syn_scope;
  top.syn_scope = list.syn_scope;
}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  top.pp = top.tab_level ++ "bindlist_list()";

  top.syn_scope = top.inh_scope; -- inherited (parent) scope unchanged
}



------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  top.pp = top.tab_level ++ "exp_letpar(\n" ++ list.pp ++ ",\n" 
    ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  list.tab_level = tab_spacing ++ top.tab_level;
  exp.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(top.inh_scope), 
    top.inh_scope.declarations, 
    top.inh_scope.references, 
    top.inh_scope.imports
  );
  list.inh_scope = top.inh_scope;
  list.inh_scope_two = init_scope;
  exp.inh_scope = list.syn_scope_two;
  top.syn_scope = list.syn_scope;
}

-- Defines the binding pattern for the parallel let feature
abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{
  top.pp = top.tab_level ++ "bindlist_list(\n" ++ top.tab_level ++ tab_spacing 
    ++ id.lexeme ++ " = " ++ exp.pp ++ ",\n" ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(top.inh_scope_two), 
    (id.lexeme, nothing())::top.inh_scope_two.declarations, 
    top.inh_scope_two.references, 
    top.inh_scope_two.imports
  );
  exp.inh_scope = top.inh_scope;
  list.inh_scope = exp.syn_scope;
  list.inh_scope_two = init_scope;
  top.syn_scope = list.syn_scope;
}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  top.pp = top.tab_level ++ "bindlist_nothing()";

  top.syn_scope = top.inh_scope;
  top.syn_scope_two = top.inh_scope_two;
}



------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = top.tab_level ++ "fun/fix(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n"
    ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    just(top.inh_scope), 
    (id.lexeme, nothing())::top.inh_scope.declarations, 
    top.inh_scope.references, 
    top.inh_scope.imports
  );
  exp.inh_scope = init_scope;
  top.syn_scope = top.inh_scope; -- inherited (parent) scope does not change
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = top.tab_level ++ "add(\n" ++ expLeft.pp ++ ",\n" 
    ++ expRight.pp ++ "\n" ++ top.tab_level ++ ")";
  expLeft.tab_level = tab_spacing ++ top.tab_level;
  expRight.tab_level = tab_spacing ++ top.tab_level;

  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = expLeft.syn_scope;
  top.syn_scope = expRight.syn_scope;
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = top.tab_level ++ "apply(\n" ++ expLeft.pp ++ ",\n" 
    ++ expRight.pp ++ "\n" ++ top.tab_level ++ ")";
  expLeft.tab_level = tab_spacing ++ top.tab_level;
  expRight.tab_level = tab_spacing ++ top.tab_level;

  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = expLeft.syn_scope;
  top.syn_scope = expRight.syn_scope;
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = top.tab_level ++ "exp_qid(\n" ++ qid.pp ++ "\n" ++ top.tab_level ++ ")";
  qid.tab_level = tab_spacing ++ top.tab_level;

  qid.inh_scope = top.inh_scope;
  qid.inh_scope_iqid = qid.syn_scope;

  top.syn_scope = qid.syn_apply_iqid;
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = top.tab_level ++ "exp_int(\n" ++ top.tab_level ++ tab_spacing 
    ++ val.lexeme ++ "\n" ++ top.tab_level ++ ")";
}



------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

inherited attribute inh_scope_iqid::Scope<Decorated Exp> occurs on Qid;
synthesized attribute syn_apply_iqid::Scope<Decorated Exp> occurs on Qid;

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = top.tab_level ++ "qid(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n" 
    ++ qid.pp ++ "\n" ++ top.tab_level ++ ")";
  qid.tab_level = tab_spacing ++ top.tab_level;

  qid.inh_scope_iqid = top.inh_scope_iqid;

  -- Have to create a new scope at this point so that we can add the reference to id  
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    top.inh_scope.parent, 
    top.inh_scope.declarations, 
    id.lexeme::top.inh_scope.references, 
    top.inh_scope.imports
  );

  local attribute new_scope::Scope<Decorated Exp> = cons_scope(
    nothing(),
    [],
    [],
    [id.lexeme]     -- come back to this - need to work out imports, should add (id, something) to imports for this scope
  );
  qid.inh_scope = new_scope;
  top.syn_scope = init_scope;
  top.syn_apply_iqid = qid.syn_apply_iqid;
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = top.tab_level ++ "qid(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ "\n" 
    ++ top.tab_level ++ ")";

  -- Have to create a new scope at this point so that we can add the reference to id
  local attribute init_scope::Scope<Decorated Exp> = cons_scope(
    top.inh_scope.parent, 
    top.inh_scope.declarations, 
    id.lexeme::top.inh_scope.references, 
    top.inh_scope.imports
  );

  -- iqid
  local attribute iqid_scope::Scope<Decorated Exp> = cons_scope(
    top.inh_scope_iqid.parent, 
    top.inh_scope_iqid.declarations, 
    top.inh_scope_iqid.references, 
    id.lexeme::top.inh_scope_iqid.imports
  );

  top.syn_scope = init_scope;
  top.syn_apply_iqid = iqid_scope;
}