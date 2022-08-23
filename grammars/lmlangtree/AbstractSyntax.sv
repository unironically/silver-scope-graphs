grammar lmlangtree;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;
nonterminal IdDcl;
nonterminal IdRef;

-- Attributes used in printing an AST
synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar, IdDcl, IdRef;

-- The inherited scope passed to a node is the scope in which the corresponding construct resides
-- Only the binding list of parrallel let expressions use two inherited scopes
inherited attribute inh_scope::sg:Scope<IdDcl IdRef> occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_two::sg:Scope<IdDcl IdRef> occurs on BindListPar, Qid;

monoid attribute all_scopes::[sg:Scope<IdDcl IdRef>] occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- Information required for constructing scope nodes with references, declarations and imports
-- Sub-expressions can synthesize each of these, which must be given to the enclosing scope
-- Only the binding list of parrallel let expressions use two synthesized attributes for each
monoid attribute decls::[sg:Decl<IdDcl IdRef>] occurs on DeclList, 
  Decl, Qid, Exp,BindListSeq, BindListRec, BindListPar;
monoid attribute refs::[sg:Ref<IdDcl IdRef>] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
monoid attribute imps::[sg:Ref<IdDcl IdRef>] occurs on DeclList, 
  Decl, Qid, Exp, BindListSeq, BindListRec, BindListPar;
monoid attribute decls_two::[sg:Decl<IdDcl IdRef>] occurs on BindListPar;
monoid attribute refs_two::[sg:Ref<IdDcl IdRef>] occurs on BindListPar;
monoid attribute imps_two::[sg:Ref<IdDcl IdRef>] occurs on BindListPar;

-- For double-edged arrow between parent and child scopes
monoid attribute children::[sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- Inherited declarations, references and imports, used by the binding lists of sequential let expressions
inherited attribute inh_decls::[sg:Decl<IdDcl IdRef>] occurs on BindListSeq;
inherited attribute inh_refs::[sg:Ref<IdDcl IdRef>] occurs on BindListSeq;
inherited attribute inh_imps::[sg:Ref<IdDcl IdRef>] occurs on BindListSeq;

-- The import synthesized in the "iqid" construct of the scope graph construction algorithm for this language example
synthesized attribute iqid_import::sg:Ref<IdDcl IdRef> occurs on Qid;

-- The scope returned by the binding list construct of a sequential let expression
synthesized attribute ret_scope::sg:Scope<IdDcl IdRef> occurs on BindListSeq;

-- Identifiers for references and declarations
attribute sg:name, sg:line, sg:column occurs on IdDcl, IdRef;
flowtype sg:name {} on IdDcl, IdRef;


------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  local attribute global_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope(
    nothing(),
    list.decls,
    list.refs,
    list.imps,
    list.children,
    nothing()
  );

  top.all_scopes := global_scope::list.all_scopes;

  list.inh_scope = global_scope;

  -- ast printing
  top.pp = "prog(" ++ list.pp ++ ")";

}


------------------------------------------------------------
---- sg:Decl lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  propagate decls, refs, imps, children, all_scopes, inh_scope;

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  propagate decls, refs, imps, children, all_scopes, inh_scope;

  -- ast printing
  top.pp = "decllist_nothing()";
}


------------------------------------------------------------
---- sg:Decls
------------------------------------------------------------

abstract production decl_module
top::Decl ::= decl::IdDcl list::DeclList
{
  local attribute module_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope(
    just(top.inh_scope),
    list.decls,
    list.refs,
    list.imps,
    list.children,
    just(module_decl)
  );

  local attribute module_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl(
    decl,
    top.inh_scope,
    just(module_scope)
  );

  top.decls := [module_decl];
  top.refs := [];
  top.imps := [];
  top.all_scopes := [module_scope] ++ list.all_scopes;
  top.children := [module_scope];

  list.inh_scope = module_scope;

  -- ast printing
  top.pp = "decl_module("++ decl.sg:name ++ "," ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  propagate decls, refs, all_scopes, children, inh_scope;
  top.imps := qid.imps ++ [qid.iqid_import]; -- rqid followed by iqid in construction rules

  qid.inh_scope_two = top.inh_scope;

  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";
}

abstract production decl_def
top::Decl ::= decl::IdDcl exp::Exp
{
  propagate refs, imps, all_scopes, children, inh_scope;

  local attribute def_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl (
    decl,
    top.inh_scope,
    nothing()
  );

  top.decls := def_decl :: exp.decls;

  -- ast printing
  top.pp = "decl_def(" ++ decl.sg:name ++ "," ++ exp.pp ++ ")";
}

abstract production decl_exp
top::Decl ::= exp::Exp
{
  propagate decls, refs, imps, all_scopes, children, inh_scope;

  -- ast printing
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
}


------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  top.decls := list.decls;
  top.refs := list.refs;
  top.imps := list.imps;
  top.all_scopes := list.all_scopes ++ exp.all_scopes;
  top.children := list.children ++ exp.children;

  list.inh_scope = top.inh_scope;
  list.inh_decls = exp.decls; -- bringing up exp's decls/refs/imports to give to the final scope in the binding list
  list.inh_refs = exp.refs;
  list.inh_imps = exp.imps;

  exp.inh_scope = list.ret_scope;

  -- ast printing
  top.pp = "exp_let(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_seq
top::BindListSeq ::= decl::IdDcl exp::Exp list::BindListSeq
{
  local attribute let_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    just(top.inh_scope),
    [let_decl],
    list.refs,
    list.imps,
    list.children,
    nothing()
  );

  local attribute let_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl (
    decl,
    top.inh_scope,
    nothing()
  );
  
  top.decls := exp.decls;
  top.refs := exp.refs;
  top.imps := exp.imps;
  top.all_scopes := [let_scope] ++ exp.all_scopes ++ list.all_scopes;
  top.ret_scope = list.ret_scope;
  top.children := [let_scope]; 

  exp.inh_scope = top.inh_scope;

  list.inh_scope = let_scope;
  list.inh_decls = top.inh_decls;
  list.inh_refs = top.inh_refs;
  list.inh_imps = top.inh_imps;

  -- ast printing
  top.pp = "bindlist_list_seq("++ decl.sg:name ++ "," ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  top.ret_scope = top.inh_scope;
  top.decls := top.inh_decls;
  top.refs := top.inh_refs;
  top.imps := top.inh_imps;
  top.all_scopes := [];
  top.children := [];

  -- ast printing
  top.pp = "bindlist_nothing_seq()";
}

------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  -- ast printing
  top.pp = "exp_letrec(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_rec
top::BindListRec ::= id::IdDcl exp::Exp list::BindListRec
{  -- ast printing
  top.pp = "bindlist_list_rec(" ++ id.sg:name ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  -- ast printing
  top.pp = "bindlist_nothing_rec()";
}


------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  -- ast printing
  top.pp = "exp_letpar(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_par
top::BindListPar ::= id::IdDcl exp::Exp list::BindListPar
{
  -- ast printing
  top.pp = "bindlist_list_par(" ++ id.sg:name ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  -- ast printing
  top.pp = "bindlist_nothing_par()";
}


------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= decl::IdDcl exp::Exp
{
  propagate decls, refs, imps, inh_scope;

  local attribute fun_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    just(top.inh_scope),
    exp.decls ++ [fun_decl],
    exp.refs,
    exp.imps,
    exp.children,
    nothing()
  );

  local attribute fun_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl (
    decl,
    fun_scope,
    nothing()
  );

  top.all_scopes := [fun_scope] ++ exp.all_scopes;
  top.children := [fun_scope];

  -- ast printing
  top.pp = "exp_funfix(" ++ decl.sg:name ++ "," ++ exp.pp ++ ")";
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  propagate decls, refs, imps, all_scopes, children, inh_scope;

  -- ast printing
  top.pp = "exp_plus(" ++ expLeft.pp ++ "," ++ expRight.pp ++ ")";
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  propagate decls, refs, imps, all_scopes, children, inh_scope;

  -- ast printing
  top.pp = "exp_app(" ++ expLeft.pp ++ "," ++ expRight.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  propagate decls, refs, imps, all_scopes, children, inh_scope;

  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  propagate decls, refs, imps, all_scopes, children, inh_scope;

  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= ref::IdRef qid::Qid
{
  local attribute qual_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    nothing(),
    [],
    qid.refs,
    [qual_ref],
    [],
    nothing()
  );

  local attribute qual_ref::sg:Ref<IdDcl IdRef> = sg:mk_ref (
    ref,
    top.inh_scope,
    sg:resolve_new(qual_ref, top.inh_scope)
  );

  qual_ref.sg:seen_imports = [qual_ref];
  qual_ref.sg:seen_scopes = [];
  
  top.decls := [];
  top.refs := [qual_ref];
  top.imps := [];
  top.iqid_import = qid.iqid_import;
  top.all_scopes := [qual_scope] ++ qid.all_scopes;
  top.children := []; 

  qid.inh_scope = qual_scope;
  qid.inh_scope_two = top.inh_scope_two;

  -- ast printing
  top.pp = "qid_list(" ++ ref.sg:name ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= ref::IdRef
{
  local attribute qual_ref::sg:Ref<IdDcl IdRef> = sg:mk_ref (
    ref,
    top.inh_scope,
    sg:resolve_new(qual_ref, top.inh_scope)
  );

  qual_ref.sg:seen_imports = [qual_ref];
  qual_ref.sg:seen_scopes = [];

  top.decls := [];
  top.refs := [qual_ref];
  top.imps := [];
  top.iqid_import = qual_ref;
  top.all_scopes := [];
  top.children := [];

  -- ast printing
  top.pp = "qid_single(" ++ ref.sg:name ++ ")";

}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

abstract production decl
top::IdDcl ::= id::ID_t
{
  top.sg:name = id.lexeme;
  top.sg:line = id.line;
  top.sg:column = id.column;

  -- ast printing
  top.pp = "decl(" ++ id.lexeme ++ ")";
}

abstract production ref
top::IdRef ::= id::ID_t
{
  top.sg:name = id.lexeme;
  top.sg:line = id.line;
  top.sg:column = id.column;

  -- ast printing
  top.pp = "ref(" ++ id.lexeme ++ ")";
}