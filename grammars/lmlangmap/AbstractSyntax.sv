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

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute tab_level::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
global tab_spacing :: String = "\t";

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

-- Error checking
synthesized attribute errors :: [String] with ++ occurs on Program, DeclList, Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
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
  [-] 2. scopes in graph nonterminal (see above). write functions in library. e.g. find all undeclared usages, compare to list of errors in program. i.e. compare the two methods of testing.
  - 3. language specific typing things?
-}
abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "program(\n" ++ list.pp ++ "\n)";
  list.tab_level = tab_spacing;
  
  local attribute init_scope::Scope_type = cons_scope(
    nothing(),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports
  );
  list.inh_scope = init_scope;

  local attribute init_graph::Graph_type = cons_graph(init_scope::list.syn_scope_list);
  top.syn_graph = init_graph;

  top.errors := list.errors;
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

  top.syn_decls = decl.syn_decls ++ list.syn_decls;
  top.syn_refs = decl.syn_refs ++ list.syn_refs;
  top.syn_imports = decl.syn_imports ++ list.syn_imports;

  decl.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;

  top.syn_scope_list = decl.syn_scope_list ++ list.syn_scope_list;

  top.errors := decl.errors ++ list.errors;
}

abstract production decllist_nothing
top::DeclList ::=
{
  top.pp = top.tab_level ++ "decl_list()";

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  top.errors := [];
}



------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  top.pp = top.tab_level ++ "module(\n" ++ tab_spacing ++ top.tab_level ++ id.lexeme ++ ",\n" 
    ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  list.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports
  );
  local attribute par_scope::Decorated Scope_type = top.inh_scope; -- Cannot simply use top.inh_scope in cons_decl(?)
  local attribute init_decl::Decl_type = cons_decl(
    id.lexeme,
    par_scope, -- Cannot simply use top.inh_scope in cons_decl(?)
    just(init_scope)
  );
  top.syn_decls = [(id.lexeme, init_decl)];
  top.syn_refs = [];
  top.syn_imports = [];
  list.inh_scope = init_scope;

  top.syn_scope_list = [init_scope] ++ list.syn_scope_list;

  top.errors := list.errors;
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  top.pp = top.tab_level ++ "import(\n" ++ qid.pp ++ "\n" ++ top.tab_level ++ ")";
  qid.tab_level = top.tab_level ++ tab_spacing;

  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports ++ [qid.syn_iqid_import]; -- rqid followed by iqid in construction rules

  top.errors := qid.errors;

  qid.inh_scope = top.inh_scope;
  qid.inh_scope_two = top.inh_scope;

  top.syn_scope_list = qid.syn_scope_list;
}

abstract production decl_def
top::Decl ::= id::ID_t exp::Exp
{
  top.pp = top.tab_level ++ "def(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n"
    ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing()
  );
  top.syn_decls = [(id.lexeme, init_decl)] ++ exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  exp.inh_scope = top.inh_scope;

  top.syn_scope_list = exp.syn_scope_list;

  top.errors := exp.errors;
}

abstract production decl_exp
-- (un)removing this for now to (not) comply with the grammar in a theory of name resolution
top::Decl ::= exp::Exp
{
  top.pp = top.tab_level ++ "decl_exp(\n" ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;

  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = top.syn_imports;

  top.syn_scope_list = exp.syn_scope_list;

  top.errors := exp.errors;
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
  top.pp = top.tab_level ++ "let(\n" ++ list.pp ++ ",\n" ++ exp.pp ++ "\n" ++ top.tab_level ++ ")";
  list.tab_level = tab_spacing ++ top.tab_level;
  exp.tab_level = tab_spacing ++ top.tab_level;

  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  
  exp.inh_scope = list.ret_scope;

  list.inh_scope = top.inh_scope;

  top.syn_scope_list = list.syn_scope_list ++ exp.syn_scope_list;

  top.errors := exp.errors;
}

-- Defines the binding pattern for the sequential let feature
abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  top.pp = top.tab_level ++ "bind_list(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n" 
    ++ exp.pp ++ ",\n" ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  exp.inh_scope = top.inh_scope;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing()
  );
  local attribute init_scope::Scope_type = cons_scope (
    just(top.inh_scope),
    [(id.lexeme, init_decl)], -- ++ list.syn_decls (same for below),
    [],
    []
  );
  list.inh_scope = init_scope;
  top.ret_scope = list.ret_scope;

  top.syn_scope_list = [init_scope] ++ exp.syn_scope_list ++ list.syn_scope_list;

  top.errors := exp.errors ++ list.errors;
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  top.pp = top.tab_level ++ "bind_list()";
  top.ret_scope = top.inh_scope;
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  top.errors := [];
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

}

-- Defines the binding pattern for the recursive let feature
abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  top.pp = top.tab_level ++ "bindlist_list(\n" ++ top.tab_level ++ tab_spacing 
    ++ id.lexeme ++ " = " ++ exp.pp ++ ",\n" ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing()
  );
  top.syn_decls = exp.syn_decls ++ list.syn_decls ++ [(id.lexeme, init_decl)];
  top.syn_refs = exp.syn_refs ++ list.syn_refs;
  top.syn_imports = exp.syn_imports ++ list.syn_imports;
  exp.inh_scope = top.inh_scope;
  list.inh_scope = top.inh_scope;

  top.syn_scope_list = exp.syn_scope_list ++ list.syn_scope_list;
}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  top.pp = top.tab_level ++ "bindlist_list()";
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];
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
}

-- Defines the binding pattern for the parallel let feature
abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{
  top.pp = top.tab_level ++ "bindlist_list(\n" ++ top.tab_level ++ tab_spacing 
    ++ id.lexeme ++ " = " ++ exp.pp ++ ",\n" ++ list.pp ++ "\n" ++ top.tab_level ++ ")";
  exp.tab_level = tab_spacing ++ top.tab_level;
  list.tab_level = tab_spacing ++ top.tab_level;

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing()
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

}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  top.pp = top.tab_level ++ "bindlist_nothing()";

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_decls_two = [];
  top.syn_refs_two = [];
  top.syn_imports_two = [];

  top.syn_scope_list = [];
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

  local attribute init_decl::Decl_type = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing()
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

  top.errors := exp.errors;
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = top.tab_level ++ "add(\n" ++ expLeft.pp ++ ",\n" 
    ++ expRight.pp ++ "\n" ++ top.tab_level ++ ")";
  expLeft.tab_level = tab_spacing ++ top.tab_level;
  expRight.tab_level = tab_spacing ++ top.tab_level;

  top.syn_decls = expLeft.syn_decls ++ expRight.syn_decls;
  top.syn_refs = expLeft.syn_refs ++ expRight.syn_refs;
  top.syn_imports = expLeft.syn_imports ++ expRight.syn_imports;

  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = top.inh_scope;

  top.syn_scope_list = expLeft.syn_scope_list ++ expRight.syn_scope_list;

  top.errors := expLeft.errors ++ expRight.errors;
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = top.tab_level ++ "apply(\n" ++ expLeft.pp ++ ",\n" 
    ++ expRight.pp ++ "\n" ++ top.tab_level ++ ")";
  expLeft.tab_level = tab_spacing ++ top.tab_level;
  expRight.tab_level = tab_spacing ++ top.tab_level;

  top.syn_decls = expLeft.syn_decls ++ expRight.syn_decls;
  top.syn_refs = expLeft.syn_refs ++ expRight.syn_refs;
  top.syn_imports = expLeft.syn_imports ++ expRight.syn_imports;

  expLeft.inh_scope = top.inh_scope;
  expRight.inh_scope = top.inh_scope;

  top.syn_scope_list = expLeft.syn_scope_list ++ expRight.syn_scope_list;

  top.errors := expLeft.errors ++ expRight.errors;
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = top.tab_level ++ "exp_qid(\n" ++ qid.pp ++ "\n" ++ top.tab_level ++ ")";
  qid.tab_level = tab_spacing ++ top.tab_level;

  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports;

  qid.inh_scope = top.inh_scope;

  top.syn_scope_list = qid.syn_scope_list;

  top.errors := qid.errors;
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = top.tab_level ++ "exp_int(\n" ++ top.tab_level ++ tab_spacing 
    ++ val.lexeme ++ "\n" ++ top.tab_level ++ ")";
  
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];

  top.syn_scope_list = [];

  top.errors := [];
}



------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

synthesized attribute syn_last_ref::Decorated Usage_type occurs on Qid;

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = top.tab_level ++ "qid(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ ",\n" 
    ++ qid.pp ++ "\n" ++ top.tab_level ++ ")";
  qid.tab_level = tab_spacing ++ top.tab_level;

  -- iqid
  qid.inh_scope_two = top.inh_scope_two;
  top.syn_iqid_import = qid.syn_iqid_import;

  -- rqid
  local attribute init_usage::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope
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

  top.errors := [];
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = top.tab_level ++ "qid(\n" ++ top.tab_level ++ tab_spacing ++ id.lexeme ++ "\n" 
    ++ top.tab_level ++ ")";

  -- iqid
  local attribute init_import_two::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope_two
  );
  top.syn_iqid_import = (id.lexeme, init_import_two);

  -- rqid:
  local attribute init_import::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope
  );
  top.syn_decls = [];
  top.syn_refs = [(id.lexeme, init_import)];
  top.syn_imports = [];

  top.syn_scope_list = [];

  ----------------------------
  -- checking with scope graph

  local attribute resolved::[Decorated Decl_type] = resolve([], init_import);

  top.errors := if (length(resolved) == 0) then
    ["Reference " ++ id.lexeme ++ " has no declaration!\n"]
  -- other cases... 
  else
    [];

}