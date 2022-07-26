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

-- Attributes used in printing an AST
synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- The inherited scope passed to a node is the scope in which the corresponding construct resides
-- Only the binding list of parrallel let expressions use two inherited scopes
inherited attribute inh_scope::Decorated Scope occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_two::Decorated Scope occurs on BindListPar, Qid;

-- Information required for synthesizing a graph node at the root of an AST
synthesized attribute syn_graph::Decorated Graph occurs on Program;
synthesized attribute syn_all_scopes::[Decorated Scope] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- Information required for constructing scope nodes with references, declarations and imports
-- Sub-expressions can synthesize each of these, which must be given to the enclosing scope
-- Only the binding list of parrallel let expressions use two synthesized attributes for each
synthesized attribute syn_decls::[Decorated Declaration] occurs on DeclList, 
  Decl, Qid, Exp,BindListSeq, BindListRec, BindListPar;
synthesized attribute syn_refs::[Decorated Usage] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
synthesized attribute syn_imports::[Decorated Usage] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
synthesized attribute syn_decls_two::[Decorated Declaration] occurs on BindListPar;
synthesized attribute syn_refs_two::[Decorated Usage] occurs on BindListPar;
synthesized attribute syn_imports_two::[Decorated Usage] occurs on BindListPar;

-- For double-edged arrow between parent and child scopes
synthesized attribute syn_scopes::[Decorated Scope] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- Inherited declarations, references and imports, used by the binding lists of sequential let expressions
inherited attribute inh_decls::[Decorated Declaration] occurs on BindListSeq;
inherited attribute inh_refs::[Decorated Usage] occurs on BindListSeq;
inherited attribute inh_imports::[Decorated Usage] occurs on BindListSeq;

-- The import synthesized in the "iqid" construct of the scope graph construction algorithm for this language example
synthesized attribute syn_iqid_import::Decorated Usage occurs on Qid;

-- The scope returned by the binding list construct of a sequential let expression
synthesized attribute ret_scope::Decorated Scope occurs on BindListSeq;

-- The lists of errors and paths found in scope graph resolution
synthesized attribute paths::[Decorated Path] occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  local attribute init_scope::Scope = cons_scope(
    nothing(),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes,
    nothing()
  );
  
  local attribute init_graph::Graph = cons_graph(init_scope::list.syn_all_scopes);
  top.syn_graph = init_graph; -- simply substituting cons_graph(...) here does not work

  list.inh_scope = init_scope;

  -- path handling
  {-
  -- collect all of the declarations that some reference is resolved to
  local attribute used_decls::[Decorated Declaration] = map((\path::Decorated Path -> path.final), list.paths);

  -- create a list from the list of all declarations in a graph
  -- each declaration in the list is mapped to a boolean indicating whether it is ever referred to
  -- e.g. (x, false) is in 'mapped' if x is a declaration and is not referred to
  local attribute mapped::[(Decorated Declaration, Boolean)] = map(
    (\decl::Decorated Declaration 
      -> (decl, containsBy(
        (\l::Decorated Declaration r::Decorated Declaration -> l.to_string == r.to_string), 
        decl, used_decls))), 
    init_graph.all_decls);

  -- use the above lists to generate errors where declarations exist which are not referred to
  top.errors = list.errors ++ foldl((
    \errors::[Decorated Error] decl_pair::(Decorated Declaration, Boolean) 
      -> errors ++ (if !snd(decl_pair) then [  decorate_err(fst(decl_pair))  ] else []) -- had to use decorate_err function instead of declaration_unused constructor?? replace with "decorate foo() with {}"?
  ), [], mapped);
  -}
  top.paths = list.paths;
  
  -- ast printing
  top.pp = "prog(" ++ list.pp ++ ")";

}

@{-
 - Had to create this function so that I can generate a decorated error.
 - Simply using the declaration_unused constructor in the above code resulted in wrong typing.
 - See comment in lines above where used.
 -
 - @param decl The declaration that is never used.
 - @return The error node corresponding to the declaration given never being used.
-}
function decorate_err
Decorated Error ::= decl::Decorated Declaration
{
  local attribute ret_err::Error = declaration_unused(decl);
  return ret_err;
}


------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.syn_decls = decl.syn_decls ++ list.syn_decls;
  top.syn_refs = decl.syn_refs ++ list.syn_refs;
  top.syn_imports = decl.syn_imports ++ list.syn_imports;
  top.syn_all_scopes = decl.syn_all_scopes ++ list.syn_all_scopes;
  top.syn_scopes = decl.syn_scopes ++ list.syn_scopes;

  decl.inh_scope = top.inh_scope;

  list.inh_scope = top.inh_scope;

  -- path handling
  top.paths = decl.paths ++ list.paths;

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";

}

abstract production decllist_nothing
top::DeclList ::=
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- path handling
  top.paths = [];

  -- ast printing
  top.pp = "decllist_nothing()";

}


------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  local attribute init_scope::Scope = cons_scope (
    just(top.inh_scope),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes,
    just(init_decl)
  );

  local attribute init_decl::Declaration = cons_decl(
    id.lexeme,
    top.inh_scope,
    just(init_scope),
    id.line,
    id.column
  );

  top.syn_decls = [init_decl];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [init_scope] ++ list.syn_all_scopes;
  top.syn_scopes = [init_scope];

  list.inh_scope = init_scope;

  -- path handling
  top.paths = list.paths;

  -- ast printing
  top.pp = "decl_module("++ id.lexeme ++ "," ++ list.pp ++ ")";

}

abstract production decl_import
top::Decl ::= qid::Qid
{
  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports ++ [qid.syn_iqid_import]; -- rqid followed by iqid in construction rules
  top.syn_all_scopes = qid.syn_all_scopes;
  top.syn_scopes = qid.syn_scopes;

  qid.inh_scope = top.inh_scope;
  qid.inh_scope_two = top.inh_scope;

  -- path handling
  top.paths = qid.paths;

  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";

}

abstract production decl_def
top::Decl ::= id::ID_t exp::Exp
{
  local attribute init_decl::Declaration = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls = [init_decl] ++ exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  top.syn_all_scopes = exp.syn_all_scopes;
  top.syn_scopes = exp.syn_scopes;

  exp.inh_scope = top.inh_scope;

  -- path handling
  top.paths = exp.paths;

  -- ast printing
  top.pp = "decl_def(" ++ id.lexeme ++ "," ++ exp.pp ++ ")";

}

abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  top.syn_all_scopes = exp.syn_all_scopes;
  top.syn_scopes = exp.syn_scopes;

  exp.inh_scope = top.inh_scope;

  -- path handling
  top.paths = exp.paths;

  -- ast printing
  top.pp = "decl_exp(" ++ exp.pp ++ ")";

}


------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  top.syn_all_scopes = list.syn_all_scopes ++ exp.syn_all_scopes;
  top.syn_scopes = list.syn_scopes ++ exp.syn_scopes;

  list.inh_scope = top.inh_scope;
  list.inh_decls = exp.syn_decls; -- bringing up exp's decls/refs/imports to give to the final scope in the binding list
  list.inh_refs = exp.syn_refs;
  list.inh_imports = exp.syn_imports;

  exp.inh_scope = list.ret_scope;
  
  -- path handling
  top.paths = list.paths ++ exp.paths;

  -- ast printing
  top.pp = "exp_let(" ++ list.pp ++ "," ++ exp.pp ++ ")";

}

abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  local attribute init_scope::Scope = cons_scope (
    just(top.inh_scope),
    [init_decl],
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes,
    nothing()
  );

  local attribute init_decl::Declaration = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );
  
  top.syn_decls = exp.syn_decls;
  top.syn_refs = exp.syn_refs;
  top.syn_imports = exp.syn_imports;
  top.syn_all_scopes = [init_scope] ++ exp.syn_all_scopes ++ list.syn_all_scopes;
  top.ret_scope = list.ret_scope;
  top.syn_scopes = [init_scope];

  exp.inh_scope = top.inh_scope;

  list.inh_scope = init_scope;
  list.inh_decls = top.inh_decls;
  list.inh_refs = top.inh_refs;
  list.inh_imports = top.inh_imports;

  -- path handling
  top.paths = exp.paths ++ list.paths;

  -- ast printing
  top.pp = "bindlist_list_seq("++ id.lexeme ++ "," ++ exp.pp ++ "," ++ list.pp ++ ")";

}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  top.ret_scope = top.inh_scope;
  top.syn_decls = top.inh_decls;
  top.syn_refs = top.inh_refs;
  top.syn_imports = top.inh_imports;
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- path handling
  top.paths = [];

  -- ast printing
  top.pp = "bindlist_nothing_seq()";

}


------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  local attribute init_scope::Scope = cons_scope (
    just(top.inh_scope),
    list.syn_decls ++ exp.syn_decls,
    list.syn_refs ++ exp.syn_refs,
    list.syn_imports ++ exp.syn_imports,
    [], -- TODO
    nothing()
  );

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [init_scope] ++ list.syn_all_scopes ++ exp.syn_all_scopes;

  list.inh_scope = init_scope;

  exp.inh_scope = init_scope;

  -- path handling
  top.paths = list.paths ++ exp.paths;

  -- ast printing
  top.pp = "exp_letrec(" ++ list.pp ++ "," ++ exp.pp ++ ")";

}

abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{
  local attribute init_decl::Declaration = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls = exp.syn_decls ++ list.syn_decls ++ [init_decl];
  top.syn_refs = exp.syn_refs ++ list.syn_refs;
  top.syn_imports = exp.syn_imports ++ list.syn_imports;
  top.syn_all_scopes = exp.syn_all_scopes ++ list.syn_all_scopes;

  list.inh_scope = top.inh_scope;

  exp.inh_scope = top.inh_scope;

  -- path handling
  top.paths = exp.paths ++ list.paths;

  -- ast printing
  top.pp = "bindlist_list_rec(" ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";

}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [];

  -- path handling
  top.paths = [];

  -- ast printing
  top.pp = "bindlist_nothing_rec()";

}


------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  local attribute init_scope::Scope = cons_scope (
    just(top.inh_scope),
    list.syn_decls_two ++ exp.syn_decls,
    list.syn_refs_two ++ exp.syn_refs,
    list.syn_imports_two ++ exp.syn_imports,
    [], -- TODO
    nothing()
  );

  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  top.syn_all_scopes = [init_scope] ++ list.syn_all_scopes ++ exp.syn_all_scopes;

  list.inh_scope = top.inh_scope;
  list.inh_scope_two = init_scope;

  exp.inh_scope = init_scope;

  -- path handling
  top.paths = list.paths ++ exp.paths;

  -- ast printing
  top.pp = "exp_letpar(" ++ list.pp ++ "," ++ exp.pp ++ ")";

}

abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{
  local attribute init_decl::Declaration = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls = exp.syn_decls ++ list.syn_decls;
  top.syn_refs = exp.syn_refs ++ list.syn_refs;
  top.syn_imports = exp.syn_imports ++ list.syn_imports;
  top.syn_decls_two = list.syn_decls_two ++ [init_decl];
  top.syn_refs_two = list.syn_refs_two;
  top.syn_imports_two = list.syn_imports_two;
  top.syn_all_scopes = exp.syn_all_scopes ++ list.syn_all_scopes;

  exp.inh_scope = top.inh_scope;

  list.inh_scope = top.inh_scope;
  list.inh_scope_two = top.inh_scope_two;

  -- path handling
  top.paths = exp.paths ++ list.paths;

  -- ast printing
  top.pp = "bindlist_list_par(" ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";

}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_decls_two = [];
  top.syn_refs_two = [];
  top.syn_imports_two = [];
  top.syn_all_scopes = [];

  -- path handling
  top.paths = [];
  
  -- ast printing
  top.pp = "bindlist_nothing_par()";

}


------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= id::ID_t exp::Exp
{
  local attribute init_scope::Scope = cons_scope (
    just(top.inh_scope),
    exp.syn_decls ++ [init_decl],
    exp.syn_refs,
    exp.syn_imports,
    exp.syn_scopes,
    nothing()
  );

  local attribute init_decl::Declaration = cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [init_scope] ++ exp.syn_all_scopes;
  top.syn_scopes = [init_scope];

  exp.inh_scope = init_scope;

  -- path handling
  top.paths = exp.paths;

  -- ast printing
  top.pp = "exp_funfix(" ++ id.lexeme ++ "," ++ exp.pp ++ ")";

}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.syn_decls = expLeft.syn_decls ++ expRight.syn_decls;
  top.syn_refs = expLeft.syn_refs ++ expRight.syn_refs;
  top.syn_imports = expLeft.syn_imports ++ expRight.syn_imports;
  top.syn_all_scopes = expLeft.syn_all_scopes ++ expRight.syn_all_scopes;
  top.syn_scopes = expLeft.syn_scopes ++ expRight.syn_scopes;

  expLeft.inh_scope = top.inh_scope;

  expRight.inh_scope = top.inh_scope;

  -- path handling
  top.paths = expLeft.paths ++ expRight.paths;

  -- ast printing
  top.pp = "exp_plus(" ++ expLeft.pp ++ "," ++ expRight.pp ++ ")";

}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.syn_decls = expLeft.syn_decls ++ expRight.syn_decls;
  top.syn_refs = expLeft.syn_refs ++ expRight.syn_refs;
  top.syn_imports = expLeft.syn_imports ++ expRight.syn_imports;
  top.syn_all_scopes = expLeft.syn_all_scopes ++ expRight.syn_all_scopes;
  top.syn_scopes = expLeft.syn_scopes ++ expRight.syn_scopes;

  expLeft.inh_scope = top.inh_scope;

  expRight.inh_scope = top.inh_scope;

  -- path handling
  top.paths = expLeft.paths ++ expRight.paths;

  -- ast printing
  top.pp = "exp_app(" ++ expLeft.pp ++ "," ++ expRight.pp ++ ")";

}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports;
  top.syn_all_scopes = qid.syn_all_scopes;
  top.syn_scopes = qid.syn_scopes;

  qid.inh_scope = top.inh_scope;

  -- path handling
  top.paths = qid.paths;
 
  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";

}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- path handling
  top.paths = [];

  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";

}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

synthesized attribute syn_last_ref::Decorated Usage occurs on Qid;

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  local attribute init_scope::Scope = cons_scope (
    nothing(),
    qid.syn_decls,
    qid.syn_refs,
    qid.syn_imports ++ [init_usage],
    qid.syn_scopes,
    nothing()
  );

  local attribute init_usage::Usage = cons_usage ( -- rqid
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );

  top.syn_decls = [];
  top.syn_refs = [init_usage];
  top.syn_imports = [];
  top.syn_all_scopes = [init_scope] ++ qid.syn_all_scopes;
  top.syn_iqid_import = qid.syn_iqid_import;
  top.syn_scopes = [];
  
  qid.inh_scope = init_scope;
  qid.inh_scope_two = top.inh_scope_two;
  
  -- path handling
  top.paths = qid.paths;

  -- ast printing
  top.pp = "qid_list(" ++ id.lexeme ++ "," ++ qid.pp ++ ")";

}

abstract production qid_single
top::Qid ::= id::ID_t
{
  local attribute init_import_two::Usage = cons_usage (
    id.lexeme,
    top.inh_scope_two,
    id.line,
    id.column
  );

  local attribute init_import::Usage = cons_usage (
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );

  top.syn_decls = [];
  top.syn_refs = [init_import];
  top.syn_imports = [];
  top.syn_iqid_import = init_import_two;
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  local attribute fst_path::Path = cons_path(init_import, head(init_import.resolutions)); -- TODO: in case of errors print some paths anyway
  top.paths = [fst_path];

  -- ast printing
  top.pp = "qid_single(" ++ id.lexeme ++ ")";

}