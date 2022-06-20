grammar lmlangmap;

imports scopegraph;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;

type Target_type = Decorated Exp;
type Graph_type = Graph<Target_type>;
type Scope_type = Scope<Target_type>;
type Decl_type = Declaration<Target_type>;
type Usage_type = Usage<Target_type>;
type Error_type = Error<Target_type>;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute tab_level::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

global pp_line_spacing :: String = "";
global pp_tab_spacing :: String = "";

inherited attribute inh_scope::Decorated Scope_type occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_two::Decorated Scope_type occurs on BindListPar, Qid;

synthesized attribute syn_graph::Decorated Graph_type occurs on Program;
synthesized attribute syn_scope_list::[Decorated Scope_type] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

synthesized attribute syn_decls::[(String, Decorated Decl_type)] occurs on DeclList, 
  Decl, Qid, Exp,BindListSeq, BindListRec, BindListPar;
synthesized attribute syn_refs::[(String, Decorated Usage_type)] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
synthesized attribute syn_imports::[(String, Decorated Usage_type)] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;

synthesized attribute syn_decls_two::[(String, Decorated Decl_type)] occurs on BindListPar;
synthesized attribute syn_refs_two::[(String, Decorated Usage_type)] occurs on BindListPar;
synthesized attribute syn_imports_two::[(String, Decorated Usage_type)] occurs on BindListPar;

synthesized attribute syn_iqid_import::(String, Decorated Usage_type) occurs on Qid;

synthesized attribute ret_scope::Decorated Scope_type occurs on BindListSeq;

synthesized attribute errors::[Decorated Error_type] occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- make new errors non-terminal instead (in scope library), e.g. production "name_undeclared" which takes a usage, "multiple_found" similar, "declaration_never_used". constructed when errors found in resolution. 
-- errors attribute is list of above passed up tree. tests like "is this particular error in the list" for example programs.

------------------------------------------------------------
---- Program root
------------------------------------------------------------
{-
  - maintain sets of all scopes (, declarations, references, imports)
  - Scope type in scope.sv which carries a list of scopes
  - extend library to find all unresolved names, names with two or more (visible) declarations, declarations with no references, 

  [-] 0. reshuffle directories and import scope library
  - 1. tests (line/col number to declaration, don't worry about types (e.g. resolving to modules) for now)
  [-] 2. scopes in graph nonterminal (see above). write functions in library. e.g. find all undeclared usages, compare to list of errors in program. i.e. compare the two methods of testing. ()
  - 3. language specific typing things?
-}
abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
  list.tab_level = pp_tab_spacing;
  
  local attribute init_scope::Scope_type = cons_scope(
    nothing(),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports
  );
  list.inh_scope = init_scope;

  local attribute init_graph::Graph_type = cons_graph(init_scope::list.syn_scope_list);
  top.syn_graph = init_graph;

  -- error handlings
  top.errors = list.errors;

}


------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = top.tab_level ++ "decllist_list(" ++ decl.pp ++ "," 
    ++ list.pp ++ "" ++ top.tab_level ++ ")";
  decl.tab_level = pp_tab_spacing ++ top.tab_level;
  list.tab_level = pp_tab_spacing ++ top.tab_level; 

  top.syn_decls = decl.syn_decls ++ list.syn_decls;
  top.syn_refs = decl.syn_refs ++ list.syn_refs;
  top.syn_imports = decl.syn_imports ++ list.syn_imports;

  decl.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;

  top.syn_scope_list = decl.syn_scope_list ++ list.syn_scope_list;

  -- error handling
  top.errors = decl.errors ++ list.errors;
}

abstract production decllist_nothing
top::DeclList ::=
{
  top.pp = top.tab_level ++ "decllist_nothing()";

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  -- error handling
  top.errors = [];
}


------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  top.pp = top.tab_level ++ "decl_module(" ++ pp_tab_spacing ++ top.tab_level ++ id.lexeme ++ "," 
    ++ list.pp ++ "" ++ top.tab_level ++ ")";
  list.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports
  );
  local attribute init_decl::Decl_type = cons_decl(
    id.lexeme,
    top.inh_scope,
    just(init_scope),
    id.line,
    id.column
  );
  top.syn_decls = [(id.lexeme, init_decl)];
  top.syn_refs = [];
  top.syn_imports = [];
  list.inh_scope = init_scope;

  top.syn_scope_list = [init_scope] ++ list.syn_scope_list;

  -- error handling
  top.errors = list.errors;

}

abstract production decl_import
top::Decl ::= qid::Qid
{
  top.pp = top.tab_level ++ "decl_import(" ++ qid.pp ++ "" ++ top.tab_level ++ ")";
  qid.tab_level = top.tab_level ++ pp_tab_spacing;

  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports ++ [qid.syn_iqid_import]; -- rqid followed by iqid in construction rules


  qid.inh_scope = top.inh_scope;
  qid.inh_scope_two = top.inh_scope;

  top.syn_scope_list = qid.syn_scope_list;

  -- error handling
  top.errors = qid.errors;
}

abstract production decl_def
top::Decl ::= id::ID_t exp::Exp
{
  top.pp = top.tab_level ++ "decl_def(" ++ top.tab_level ++ pp_tab_spacing ++ id.lexeme ++ ","
    ++ exp.pp ++ "" ++ top.tab_level ++ ")";
  exp.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );
  top.syn_decls = [(id.lexeme, init_decl)] ++ exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  exp.inh_scope = top.inh_scope;

  top.syn_scope_list = exp.syn_scope_list;

  -- error handling
  top.errors = exp.errors;

}

abstract production decl_exp
-- (un)removing this for now to (not) comply with the grammar in a theory of name resolution
top::Decl ::= exp::Exp
{
  top.pp = top.tab_level ++ "decl_exp(" ++ exp.pp ++ "" ++ top.tab_level ++ ")";
  exp.tab_level = pp_tab_spacing ++ top.tab_level;

  exp.inh_scope = top.inh_scope;

  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;

  top.syn_scope_list = exp.syn_scope_list;

  -- error handling
  top.errors = exp.errors;

}


------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------
{-
reshuffle:
 - lm grammars directory
 - other grammar directories for other languages
 - scope library directory (import)

write tests - testing framework in silver (call parser for example programs) - perhaps use line number for the indices to names in the paper
-}
abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.pp = top.tab_level ++ "exp_let(" ++ list.pp ++ "," ++ exp.pp ++ "" ++ top.tab_level ++ ")";
  list.tab_level = pp_tab_spacing ++ top.tab_level;
  exp.tab_level = pp_tab_spacing ++ top.tab_level;

  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  
  exp.inh_scope = list.ret_scope;

  list.inh_scope = top.inh_scope;

  top.syn_scope_list = list.syn_scope_list ++ exp.syn_scope_list;

  -- error handling
  top.errors = list.errors ++ exp.errors;

}

-- Defines the binding pattern for the sequential let feature
abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  top.pp = top.tab_level ++ "bindlist_list_seq(" ++ top.tab_level ++ pp_tab_spacing ++ id.lexeme ++ "," 
    ++ exp.pp ++ "," ++ list.pp ++ "" ++ top.tab_level ++ ")";
  exp.tab_level = pp_tab_spacing ++ top.tab_level;
  list.tab_level = pp_tab_spacing ++ top.tab_level;

  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  exp.inh_scope = top.inh_scope;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );
  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    [(id.lexeme, init_decl)],
    [],
    []
  );
  list.inh_scope = init_scope;
  top.ret_scope = list.ret_scope;

  top.syn_scope_list = [init_scope] ++ exp.syn_scope_list ++ list.syn_scope_list;

  -- error handling
  top.errors = exp.errors ++ list.errors;

}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  top.pp = top.tab_level ++ "bindlist_nothing_seq()";
  top.ret_scope = top.inh_scope;
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  -- error handling
  top.errors = [];

}


------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  top.pp = top.tab_level ++ "exp_letrec(" ++ list.pp ++ "," 
    ++ exp.pp ++ "" ++ top.tab_level ++ ")";
  list.tab_level = pp_tab_spacing ++ top.tab_level;
  exp.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    list.syn_decls ++ exp.syn_decls,
    list.syn_refs ++ exp.syn_refs,
    list.syn_imports ++ exp.syn_imports 
  );

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  list.inh_scope = init_scope;
  exp.inh_scope = init_scope;

  top.syn_scope_list = [init_scope] ++ list.syn_scope_list ++ exp.syn_scope_list;

  -- error handling
  top.errors = list.errors ++ exp.errors;


}

-- Defines the binding pattern for the recursive let feature
abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  top.pp = top.tab_level ++ "bindlist_list_rec(" ++ top.tab_level ++ pp_tab_spacing 
    ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ "" ++ top.tab_level ++ ")";
  exp.tab_level = pp_tab_spacing ++ top.tab_level;
  list.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );
  top.syn_decls = exp.syn_decls ++ list.syn_decls ++ [(id.lexeme, init_decl)];
  top.syn_refs = exp.syn_refs ++ list.syn_refs;
  top.syn_imports = exp.syn_imports ++ list.syn_imports;
  exp.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;

  top.syn_scope_list = exp.syn_scope_list ++ list.syn_scope_list;

  -- error handling
  top.errors = exp.errors ++ list.errors;


}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  top.pp = top.tab_level ++ "bindlist_nothing_rec()";
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  -- error handling
  top.errors = [];

}


------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  top.pp = top.tab_level ++ "exp_letpar(" ++ list.pp ++ "," 
    ++ exp.pp ++ "" ++ top.tab_level ++ ")";
  list.tab_level = pp_tab_spacing ++ top.tab_level;
  exp.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    list.syn_decls_two ++ exp.syn_decls,
    list.syn_refs_two ++ exp.syn_refs,
    list.syn_imports_two ++ exp.syn_imports 
  );

  exp.inh_scope = init_scope;
  list.inh_scope = top.inh_scope;
  list.inh_scope_two = init_scope;

  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;

  top.syn_scope_list = [init_scope] ++ list.syn_scope_list ++ exp.syn_scope_list;

  -- error handling
  top.errors = list.errors ++ exp.errors;

}

-- Defines the binding pattern for the parallel let feature
abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{
  top.pp = top.tab_level ++ "bindlist_list_par(" ++ top.tab_level ++ pp_tab_spacing 
    ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ "" ++ top.tab_level ++ ")";
  exp.tab_level = pp_tab_spacing ++ top.tab_level;
  list.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;

  top.syn_decls_two = list.syn_decls_two ++ [(id.lexeme, init_decl)];
  top.syn_refs_two = list.syn_refs_two;
  top.syn_imports_two = list.syn_imports_two;

  exp.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;
  list.inh_scope_two = top.inh_scope_two;

  top.syn_scope_list = exp.syn_scope_list ++ list.syn_scope_list;

  -- error handling
  top.errors = exp.errors ++ list.errors;

}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  top.pp = top.tab_level ++ "bindlist_nothing_par()";

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_decls_two = [];
  top.syn_refs_two = [];
  top.syn_imports_two = [];

  top.syn_scope_list = [];

  -- error handling
  top.errors = [];

}


------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = top.tab_level ++ "exp_funfix(" ++ top.tab_level ++ pp_tab_spacing ++ id.lexeme ++ ","
    ++ exp.pp ++ "" ++ top.tab_level ++ ")";
  exp.tab_level = pp_tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    exp.syn_decls ++ [(id.lexeme, init_decl)],
    exp.syn_refs,
    exp.syn_imports
  );

  exp.inh_scope = init_scope;

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [init_scope] ++ exp.syn_scope_list;

  -- error handling
  top.errors = exp.errors;

}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = top.tab_level ++ "exp_plus(" ++ expLeft.pp ++ "," 
    ++ expRight.pp ++ "" ++ top.tab_level ++ ")";
  expLeft.tab_level = pp_tab_spacing ++ top.tab_level;
  expRight.tab_level = pp_tab_spacing ++ top.tab_level;

  top.syn_decls = expLeft.syn_decls ++ expRight.syn_decls;
  top.syn_refs = expLeft.syn_refs ++ expRight.syn_refs;
  top.syn_imports = expLeft.syn_imports ++ expRight.syn_imports;

  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = top.inh_scope;

  top.syn_scope_list = expLeft.syn_scope_list ++ expRight.syn_scope_list;

  -- error handling
  top.errors = expLeft.errors ++ expRight.errors;
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = top.tab_level ++ "exp_app(" ++ expLeft.pp ++ "," 
    ++ expRight.pp ++ "" ++ top.tab_level ++ ")";
  expLeft.tab_level = pp_tab_spacing ++ top.tab_level;
  expRight.tab_level = pp_tab_spacing ++ top.tab_level;

  top.syn_decls = expLeft.syn_decls ++ expRight.syn_decls;
  top.syn_refs = expLeft.syn_refs ++ expRight.syn_refs;
  top.syn_imports = expLeft.syn_imports ++ expRight.syn_imports;

  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = top.inh_scope;

  top.syn_scope_list = expLeft.syn_scope_list ++ expRight.syn_scope_list;

  -- error handling
  top.errors = expLeft.errors ++ expRight.errors;

}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = top.tab_level ++ "exp_qid(" ++ qid.pp ++ "" ++ top.tab_level ++ ")";
  qid.tab_level = pp_tab_spacing ++ top.tab_level;

  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports;

  qid.inh_scope = top.inh_scope;

  top.syn_scope_list = qid.syn_scope_list;

  -- error handling
  top.errors = qid.errors;

}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = top.tab_level ++ "exp_int(" ++ top.tab_level ++ pp_tab_spacing 
    ++ val.lexeme ++ "" ++ top.tab_level ++ ")";
  
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  -- error handling
  top.errors = [];

}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

synthesized attribute syn_last_ref::Decorated Usage_type occurs on Qid;

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = top.tab_level ++ "qid_list(" ++ top.tab_level ++ pp_tab_spacing ++ id.lexeme ++ "," 
    ++ qid.pp ++ "" ++ top.tab_level ++ ")";
  qid.tab_level = pp_tab_spacing ++ top.tab_level;

  -- iqid
  qid.inh_scope_two = top.inh_scope_two;
  top.syn_iqid_import = qid.syn_iqid_import;

  -- rqid
  local attribute init_usage::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );
  local attribute init_scope::Scope_type = cons_scope (
    nothing(),
    qid.syn_decls,
    qid.syn_refs,
    qid.syn_imports ++ [(id.lexeme, init_usage)]
  );
  qid.inh_scope = init_scope;
  top.syn_decls = [];
  top.syn_refs = [(id.lexeme, init_usage)];
  top.syn_imports = [];

  top.syn_scope_list = [init_scope] ++ qid.syn_scope_list;

  -- error handling
  top.errors = qid.errors;

}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = top.tab_level ++ "qid_single(" ++ top.tab_level ++ pp_tab_spacing ++ id.lexeme ++ "" 
    ++ top.tab_level ++ ")";

  -- iqid
  local attribute init_import_two::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope_two,
    id.line,
    id.column
  );
  top.syn_iqid_import = (id.lexeme, init_import_two);

  -- rqid:
  local attribute init_import::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );
  top.syn_decls = [];
  top.syn_refs = [(id.lexeme, init_import)];
  top.syn_imports = [];

  top.syn_scope_list = [];

  -- error handling

  local attribute resolved::[Decorated Decl_type] = resolve([], init_import);

  local attribute no_decl::Error_type = no_declaration_found(init_import);
  local attribute mul_decl::Error_type = multiple_declarations_found(init_import);
  
  top.errors = if (length(resolved) < 1) then
    [no_decl]
  else if (length(resolved) > 1) then
    [mul_decl]
  else
    [];

}