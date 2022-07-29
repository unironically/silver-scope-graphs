grammar lmlangmap;

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
inherited attribute inh_scope::Decorated sg:Scope<IdDcl IdRef> occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_two::Decorated sg:Scope<IdDcl IdRef> occurs on BindListPar, Qid;

-- Information required for synthesizing a graph node at the root of an AST
synthesized attribute syn_graph::Decorated sg:Graph<IdDcl IdRef> occurs on Program;
monoid attribute syn_all_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- Information required for constructing scope nodes with references, declarations and imports
-- Sub-expressions can synthesize each of these, which must be given to the enclosing scope
-- Only the binding list of parrallel let expressions use two synthesized attributes for each
monoid attribute syn_decls::[Decorated sg:Decl<IdDcl IdRef>] occurs on DeclList, 
  Decl, Qid, Exp,BindListSeq, BindListRec, BindListPar;
monoid attribute syn_refs::[Decorated sg:Ref<IdDcl IdRef>] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
monoid attribute syn_imports::[Decorated sg:Ref<IdDcl IdRef>] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
monoid attribute syn_decls_two::[Decorated sg:Decl<IdDcl IdRef>] occurs on BindListPar;
monoid attribute syn_refs_two::[Decorated sg:Ref<IdDcl IdRef>] occurs on BindListPar;
monoid attribute syn_imports_two::[Decorated sg:Ref<IdDcl IdRef>] occurs on BindListPar;

-- For double-edged arrow between parent and child scopes
monoid attribute syn_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- Inherited declarations, references and imports, used by the binding lists of sequential let expressions
inherited attribute inh_decls::[Decorated sg:Decl<IdDcl IdRef>] occurs on BindListSeq;
inherited attribute inh_refs::[Decorated sg:Ref<IdDcl IdRef>] occurs on BindListSeq;
inherited attribute inh_imports::[Decorated sg:Ref<IdDcl IdRef>] occurs on BindListSeq;

-- The import synthesized in the "iqid" construct of the scope graph construction algorithm for this language example
synthesized attribute syn_iqid_import::Decorated sg:Ref<IdDcl IdRef> occurs on Qid;

-- The scope returned by the binding list construct of a sequential let expression
synthesized attribute ret_scope::Decorated sg:Scope<IdDcl IdRef> occurs on BindListSeq;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope(
    nothing(),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes,
    nothing()
  );
  
  local attribute init_graph::sg:Graph<IdDcl IdRef> = sg:cons_graph(init_scope::list.syn_all_scopes);
  top.syn_graph = init_graph; -- simply substituting sg:cons_graph(...) here does not work

  list.inh_scope = init_scope;

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
Decorated sg:Error<IdDcl IdRef> ::= decl::Decorated sg:Decl<IdDcl IdRef>
{
  local attribute ret_err::sg:Error<IdDcl IdRef> = sg:declaration_unused(decl);
  return ret_err;
}


------------------------------------------------------------
---- sg:Decl lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes,
            inh_scope;
  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes;
  -- ast printing
  top.pp = "decllist_nothing()";
}


------------------------------------------------------------
---- sg:Decls
------------------------------------------------------------

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope (
    just(top.inh_scope),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes,
    just(init_decl)
  );

  local attribute init_decl:: sg:Decl<IdDcl IdRef> = sg:cons_decl(
    id.lexeme,
    top.inh_scope,
    just(init_scope),
    id.line,
    id.column
  );

  top.syn_decls := [init_decl];
  top.syn_refs := [];
  top.syn_imports := [];
  top.syn_all_scopes := [init_scope] ++ list.syn_all_scopes;
  top.syn_scopes := [init_scope];

  list.inh_scope = init_scope;

  -- ast printing
  top.pp = "decl_module("++ id.lexeme ++ "," ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{ propagate syn_decls, syn_refs, syn_all_scopes, syn_scopes,
            inh_scope;

  top.syn_imports := qid.syn_imports ++ [qid.syn_iqid_import]; -- rqid followed by iqid in construction rules

  qid.inh_scope_two = top.inh_scope;

  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";
}

abstract production decl_def
top::Decl ::= id::ID_t exp::Exp
{ propagate syn_refs, syn_imports, syn_all_scopes, syn_scopes,
            inh_scope;

  local attribute init_decl::sg:Decl<IdDcl IdRef> = sg:cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls := init_decl :: exp.syn_decls;

  -- ast printing
  top.pp = "decl_def(" ++ id.lexeme ++ "," ++ exp.pp ++ ")";
}

abstract production decl_exp
top::Decl ::= exp::Exp
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes,
            inh_scope;

  -- ast printing
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
}


------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.syn_decls := list.syn_decls;
  top.syn_refs := list.syn_refs;
  top.syn_imports := list.syn_imports;
  top.syn_all_scopes := list.syn_all_scopes ++ exp.syn_all_scopes;
  top.syn_scopes := list.syn_scopes ++ exp.syn_scopes; -- ADD

  list.inh_scope = top.inh_scope;
  list.inh_decls = exp.syn_decls; -- bringing up exp's decls/refs/imports to give to the final scope in the binding list
  list.inh_refs = exp.syn_refs;
  list.inh_imports = exp.syn_imports;

  exp.inh_scope = list.ret_scope;
  
  -- ast printing
  top.pp = "exp_let(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_seq
top::BindListSeq ::= id::ID_t exp::Exp list::BindListSeq
{
  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope (
    just(top.inh_scope),
    [init_decl],
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes,
    nothing()
  );

  local attribute init_decl::sg:Decl<IdDcl IdRef> = sg:cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );
  
  top.syn_decls := exp.syn_decls;
  top.syn_refs := exp.syn_refs;
  top.syn_imports := exp.syn_imports;
  top.syn_all_scopes := [init_scope] ++ exp.syn_all_scopes ++ list.syn_all_scopes;
  top.ret_scope = list.ret_scope;
  top.syn_scopes := [init_scope]; 

  exp.inh_scope = top.inh_scope;

  list.inh_scope = init_scope;
  list.inh_decls = top.inh_decls;
  list.inh_refs = top.inh_refs;
  list.inh_imports = top.inh_imports;

  -- ast printing
  top.pp = "bindlist_list_seq("++ id.lexeme ++ "," ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
{- Luke, I think you removed equations for these but I had them in
   my fork. Are they no longer needed? -}
  top.ret_scope = top.inh_scope;
  top.syn_decls := top.inh_decls;
  top.syn_refs := top.inh_refs;
  top.syn_imports := top.inh_imports;
  top.syn_all_scopes := [];
  top.syn_scopes := [];

  -- ast printing
  top.pp = "bindlist_nothing_seq()";
}


------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope (
    just(top.inh_scope),
    list.syn_decls ++ exp.syn_decls,
    list.syn_refs ++ exp.syn_refs,
    list.syn_imports ++ exp.syn_imports,
    [], -- TODO
    nothing()
  );

  top.syn_decls := [];
  top.syn_refs := [];
  top.syn_imports := [];
  top.syn_all_scopes := [init_scope] ++ list.syn_all_scopes ++ exp.syn_all_scopes;

  list.inh_scope = init_scope;

  exp.inh_scope = init_scope;

  -- ast printing
  top.pp = "exp_letrec(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_rec
top::BindListRec ::= id::ID_t exp::Exp list::BindListRec
{ propagate syn_refs, syn_imports, syn_all_scopes,
            inh_scope;

  local attribute init_decl::sg:Decl<IdDcl IdRef> = sg:cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls := exp.syn_decls ++ list.syn_decls ++ [init_decl];

  -- ast printing
  top.pp = "bindlist_list_rec(" ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes;

  -- ast printing
  top.pp = "bindlist_nothing_rec()";
}


------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope (
    just(top.inh_scope),
    list.syn_decls_two ++ exp.syn_decls,
    list.syn_refs_two ++ exp.syn_refs,
    list.syn_imports_two ++ exp.syn_imports,
    [], -- TODO
    nothing()
  );

  top.syn_decls := list.syn_decls;
  top.syn_refs := list.syn_refs;
  top.syn_imports := list.syn_imports;
  top.syn_all_scopes := [init_scope] ++ list.syn_all_scopes ++ exp.syn_all_scopes;

  list.inh_scope = top.inh_scope;
  list.inh_scope_two = init_scope;

  exp.inh_scope = init_scope;

  -- ast printing
  top.pp = "exp_letpar(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_par
top::BindListPar ::= id::ID_t exp::Exp list::BindListPar
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes, 
            inh_scope;

  local attribute init_decl::sg:Decl<IdDcl IdRef> = sg:cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_decls_two := list.syn_decls_two ++ [init_decl];
  top.syn_refs_two := list.syn_refs_two;
  top.syn_imports_two := list.syn_imports_two;

  list.inh_scope_two = top.inh_scope_two;

  -- ast printing
  top.pp = "bindlist_list_par(" ++ id.lexeme ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_par
top::BindListPar ::=
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, 
            syn_decls_two, syn_refs_two, syn_imports_two;
  
  -- ast printing
  top.pp = "bindlist_nothing_par()";
}


------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= id::ID_t exp::Exp
{ propagate syn_decls, syn_refs, syn_imports, inh_scope;

  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope (
    just(top.inh_scope),
    exp.syn_decls ++ [init_decl],
    exp.syn_refs,
    exp.syn_imports,
    exp.syn_scopes,
    nothing()
  );

  local attribute init_decl::sg:Decl<IdDcl IdRef> = sg:cons_decl (
    id.lexeme,
    top.inh_scope,
    nothing(),
    id.line,
    id.column
  );

  top.syn_all_scopes := [init_scope] ++ exp.syn_all_scopes;
  top.syn_scopes := [init_scope]; -- ADD

  -- ast printing
  top.pp = "exp_funfix(" ++ id.lexeme ++ "," ++ exp.pp ++ ")";
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes, 
            inh_scope;

  -- ast printing
  top.pp = "exp_plus(" ++ expLeft.pp ++ "," ++ expRight.pp ++ ")";
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes, 
            inh_scope;

  -- ast printing
  top.pp = "exp_app(" ++ expLeft.pp ++ "," ++ expRight.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes,
            inh_scope;

  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{ propagate syn_decls, syn_refs, syn_imports, syn_all_scopes, syn_scopes;

  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

synthesized attribute syn_last_ref::Decorated sg:Ref<IdDcl IdRef> occurs on Qid;

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{

  -- RQID [[
  local attribute init_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope (
    nothing(),
    [],
    qid.syn_refs,
    [init_usage],
    [],
    nothing()
  );

  local attribute init_usage::sg:Ref<IdDcl IdRef> = sg:cons_usage (
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );
  
  top.syn_decls := [];
  top.syn_refs := [init_usage];
  top.syn_imports := [];
  top.syn_all_scopes := [init_scope] ++ qid.syn_all_scopes;
  top.syn_scopes := []; 

  qid.inh_scope = init_scope;
  -- ]]

  -- IQID [[
  top.syn_iqid_import = qid.syn_iqid_import;
  
  qid.inh_scope_two = top.inh_scope_two;
  -- ]]
  
  -- ast printing
  top.pp = "qid_list(" ++ id.lexeme ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  {-
  -- IQID [[
  local attribute init_import_two::sg:Ref<IdDcl IdRef> = sg:cons_usage (
    id.lexeme,
    top.inh_scope_two,
    id.line,
    id.column
  ); -- this is the one that cannot be resolved..
  -}

  --top.syn_iqid_import = init_import_two;
  -- ]]
  top.syn_iqid_import = init_import;

  -- RQID [[
  local attribute init_import::sg:Ref<IdDcl IdRef> = sg:cons_usage (
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );

  top.syn_decls := [];
  top.syn_refs := [init_import];
  top.syn_imports := [];
  top.syn_all_scopes := [];
  top.syn_scopes := [];

  -- ]]

  -- ast printing
  top.pp = "qid_single(" ++ id.lexeme ++ ")";

}

nonterminal IdDcl;
nonterminal IdRef;