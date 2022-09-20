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
-- Only the binding list of parrallel let expressions use two inherited scopes
inherited attribute inh_scope::Decorated sg:Scope<IdDcl IdRef> occurs on DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar;
inherited attribute inh_scope_two::Decorated sg:Scope<IdDcl IdRef> occurs on BindListPar, Qid;

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
    list.children
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
  propagate inh_scope, children, root_scopes;

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  propagate children, root_scopes;

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
    list.children
  );

  top.root_scopes := list.root_scopes;
  top.children := [module_scope];

  list.inh_scope = module_scope;

  -- ast printing
  top.pp = "decl_module("++ decl.sg:name ++ "," ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  propagate inh_scope, root_scopes, children;

  qid.inh_scope_two = top.inh_scope; -- change name inh_scope_two

  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";
}

abstract production decl_def
top::Decl ::= decl::IdDcl exp::Exp
{
  propagate inh_scope, root_scopes, children;

  -- ast printing
  top.pp = "decl_def(" ++ decl.sg:name ++ "," ++ exp.pp ++ ")";
}

abstract production decl_exp
top::Decl ::= exp::Exp
{
  propagate inh_scope, root_scopes, children;

  -- ast printing
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= decl::IdDcl exp::Exp
{
  propagate inh_scope;

  local attribute fun_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope (
    just(top.inh_scope),
    exp.children
  );

  top.root_scopes := exp.root_scopes;
  top.children := [fun_scope];

  -- ast printing
  top.pp = "exp_funfix(" ++ decl.sg:name ++ "," ++ exp.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  propagate inh_scope, root_scopes, children;

  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  propagate inh_scope, root_scopes, children;

  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= ref::IdRef qid::Qid
{
  local attribute qual_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope_disconnected ();

  top.root_scopes := qual_scope::qid.root_scopes;
  top.children := [];

  qid.inh_scope = qual_scope;
  qid.inh_scope_two = top.inh_scope_two;

  -- ast printing
  top.pp = "qid_list(" ++ ref.sg:name ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= ref::IdRef
{
  propagate root_scopes, children;

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