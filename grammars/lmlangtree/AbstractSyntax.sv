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

-- Entire graph, synthesized by prog
synthesized attribute graph::sg:Graph<IdDcl IdRef> occurs on Program;

-- The inherited scope passed to a node is the scope in which the corresponding construct resides
inherited attribute inh_scope::Decorated sg:Scope<IdDcl IdRef> occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_iqid::Decorated sg:Scope<IdDcl IdRef> occurs on Qid;

-- Declarations, references and imports passed up a tree to the scope they reside in
monoid attribute decls::[Decorated sg:Decl<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
monoid attribute refs::[Decorated sg:Ref<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
monoid attribute imps::[Decorated sg:Ref<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- For passing bindings down to the final scope created in a sequential let expression
-- Since all bindings and scopes stemming from the body of a sequential let are attached here
inherited attribute inh_decls::[Decorated sg:Decl<IdDcl IdRef>] occurs on BindListSeq;
inherited attribute inh_refs::[Decorated sg:Ref<IdDcl IdRef>] occurs on BindListSeq;
inherited attribute inh_imps::[Decorated sg:Ref<IdDcl IdRef>] occurs on BindListSeq;

-- The final reference in a qualified name must be an import node of the import ast node
synthesized attribute imp_iqid::Decorated sg:Ref<IdDcl IdRef> occurs on Qid;

-- Collects all the parentless scopes in the scope forest
monoid attribute root_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- For double-edged arrow between parent and child scopes
monoid attribute children::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;

-- The scope returned by the binding list construct of a sequential let expression
synthesized attribute ret_scope::Decorated sg:Scope<IdDcl IdRef> occurs on BindListSeq;

-- Identifiers for references and declarations
attribute sg:name, sg:line, sg:column occurs on IdDcl, IdRef;
flowtype sg:name {} on IdDcl, IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  local attribute graph::sg:Graph<IdDcl IdRef> = sg:mk_graph(
    global_scope::list.root_scopes
  );

  local attribute global_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope_parentless(
    list.children,
    list.decls,
    list.refs,
    list.imps
  );

  top.graph = graph;

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
  propagate inh_scope, children, root_scopes, decls, refs, imps;

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  propagate children, root_scopes, decls, refs, imps;

  -- ast printing
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- sg:Decls
------------------------------------------------------------

abstract production decl_module
top::Decl ::= decl::IdDcl list::DeclList
{
  local attribute module_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    just(top.inh_scope),
    list.children,
    list.decls,
    list.refs,
    list.imps
  );

  local attribute module_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl_assoc (
    decl,
    top.inh_scope,
    just(module_scope)
  );

  top.root_scopes := list.root_scopes;
  top.children := [module_scope];
  top.decls := [module_decl];
  top.refs := [];
  top.imps := [];


  list.inh_scope = module_scope;

  -- ast printing
  top.pp = "decl_module("++ decl.sg:name ++ "," ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  propagate inh_scope, root_scopes, children, decls, refs;

  top.imps := qid.imp_iqid::qid.imps;

  qid.inh_scope_iqid = top.inh_scope;

  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";
}

abstract production decl_def
top::Decl ::= decl::IdDcl exp::Exp
{
  propagate inh_scope, root_scopes, children, refs, imps;

  local attribute def_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl (
    decl,
    top.inh_scope
  );

  top.decls := def_decl::exp.decls;

  -- ast printing
  top.pp = "decl_def(" ++ decl.sg:name ++ "," ++ exp.pp ++ ")";
}

abstract production decl_exp
top::Decl ::= exp::Exp
{
  propagate inh_scope, root_scopes, children, decls, refs, imps;

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
  top.root_scopes := list.root_scopes ++ exp.root_scopes;
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
  local attribute sequence_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    just(top.inh_scope),
    list.children,
    [sequence_decl],
    list.refs,
    list.imps
  );

  local attribute sequence_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl (
    decl,
    top.inh_scope
  );

  top.decls := exp.decls;
  top.refs := exp.refs;
  top.imps := exp.imps;
  top.children := [sequence_scope];
  top.root_scopes := exp.root_scopes ++ list.root_scopes;
  top.ret_scope = list.ret_scope;

  exp.inh_scope = top.inh_scope;

  list.inh_scope = sequence_scope;
  list.inh_decls = top.inh_decls;
  list.inh_refs = top.inh_refs;
  list.inh_imps = top.inh_imps;

  -- ast printing
  top.pp = "bindlist_list_seq(" ++ decl.sg:name ++ "," ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  --propagate root_scopes, children, decls, refs, imps;

  top.root_scopes := [];
  top.children := [];
  top.decls := top.inh_decls;
  top.refs := top.inh_refs;
  top.imps := top.inh_imps;
  top.ret_scope = top.inh_scope;

  -- ast printing
  top.pp = "bindlist_nothing_seq()";
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= decl::IdDcl exp::Exp
{
  propagate decls, refs, imps;

  local attribute fun_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    just(top.inh_scope),
    exp.children,
    fun_decl::exp.decls,
    exp.refs,
    exp.imps
  );

  local attribute fun_decl::sg:Decl<IdDcl IdRef> = sg:mk_decl (
    decl,
    fun_scope
  );

  top.root_scopes := exp.root_scopes;
  top.children := [fun_scope];

  exp.inh_scope = fun_scope;

  -- ast printing
  top.pp = "exp_funfix(" ++ decl.sg:name ++ "," ++ exp.pp ++ ")";
}

abstract production exp_add
top::Exp ::= left::Exp right::Exp
{
  propagate root_scopes, children, decls, refs, imps, inh_scope;

  -- ast printing
  top.pp = "add(" ++ left.pp ++ "," ++ right.pp ++ ")";
}

abstract production exp_app
top::Exp ::= left::Exp right::Exp
{
  propagate root_scopes, children, decls, refs, imps, inh_scope;

  -- ast printing
  top.pp = "app(" ++ left.pp ++ "," ++ right.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  propagate inh_scope, root_scopes, children, decls, refs, imps;

  qid.inh_scope_iqid = top.inh_scope;

  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  propagate inh_scope, root_scopes, children, decls, refs, imps;

  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= ref::IdRef qid::Qid
{
  propagate inh_scope_iqid;

  local attribute qual_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope_disconnected (
    [],
    qid.refs,
    [qual_ref]
  );

  local attribute qual_ref::sg:Ref<IdDcl IdRef> = sg:mk_ref (
    ref,
    top.inh_scope,
    resolutions
  );

  top.root_scopes := qual_scope::qid.root_scopes;
  top.children := [];
  top.decls := [];
  top.refs := [qual_ref];
  top.imps := [];
  top.imp_iqid = qid.imp_iqid;

  qid.inh_scope = qual_scope;

  -- For resolution algorithm(s)
  qual_ref.sg:seen_scopes = [];
  qual_ref.sg:seen_imports = [qual_ref];

  local attribute resolutions::[Decorated sg:Decl<IdDcl IdRef>] = sg:resolve_visser([], qual_ref);

  -- ast printing
  top.pp = "qid_list(" ++ ref.sg:name ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= ref::IdRef
{
  local attribute last_ref::sg:Ref<IdDcl IdRef> = sg:mk_ref (
    ref,
    top.inh_scope_iqid,
    resolutions
  );

  top.root_scopes := [];
  top.children := [];
  top.decls := [];
  top.refs := [last_ref];
  top.imps := [];
  top.imp_iqid = last_ref;

  -- For resolution algorithm(s)
  last_ref.sg:seen_scopes = [];
  last_ref.sg:seen_imports = [last_ref];
  
  local attribute resolutions::[Decorated sg:Decl<IdDcl IdRef>] = sg:resolve_visser([], last_ref);

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