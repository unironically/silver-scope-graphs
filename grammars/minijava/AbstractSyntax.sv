grammar minijava;

imports scopegraph as sg;


nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Block;
nonterminal Extend;
nonterminal Implement;
nonterminal QidList;
nonterminal Qid;

-- Printing AST term
synthesized attribute pp::String occurs on Program, DeclList, Decl, Block, Extend, Implement, QidList, Qid;

-- Information required for constructing scope nodes with references, declarations and imports
-- Sub-expressions can synthesize each of these, which must be given to the enclosing scope
synthesized attribute syn_decls::[Decorated sg:Decl<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;
synthesized attribute syn_refs::[Decorated sg:Ref<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;
synthesized attribute syn_imports::[Decorated sg:Ref<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;

-- Information required for synthesizing a graph node at the root of an AST
synthesized attribute syn_graph::Decorated sg:Graph<IdDcl IdRef> occurs on Program;
synthesized attribute syn_all_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;

-- The inherited scope passed to a node is the scope in which the corresponding construct resides
inherited attribute inh_scope::Decorated sg:Scope<IdDcl IdRef> occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;
  inherited attribute inh_scope_two::Decorated sg:Scope<IdDcl IdRef> occurs on Qid;

-- For double-edged arrow between parent and child scopes
synthesized attribute syn_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;

-- The import synthesized in the "iqid" construct of the scope graph construction algorithm for this language example
synthesized attribute syn_iqid_import::Decorated sg:Ref<IdDcl IdRef> occurs on Qid;

------------------------------------------------------------
---- Program
------------------------------------------------------------

abstract production prog
top::Program ::= list::DeclList
{

  -- The root scope of the program
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

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- ast printing
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_class
top::Decl ::= id::ID_t extend::Extend implement::Implement block::Block
{
  -- New scope for a class
  local attribute new_scope::sg:Scope<IdDcl IdRef> = sg:cons_scope(
    just(top.inh_scope),
    block.syn_decls,
    block.syn_refs,
    block.syn_refs,
    block.syn_scopes,
    just(init_decl)
  );

  local attribute init_decl::sg:Decl<IdDcl IdRef> = sg:cons_decl(
    id.lexeme,
    top.inh_scope,
    just(new_scope),
    id.line,
    id.column
  );

  top.syn_decls = [init_decl] ++ extend.syn_decls ++ implement.syn_decls;
  top.syn_refs = extend.syn_refs ++ implement.syn_refs;
  top.syn_imports = extend.syn_imports ++ implement.syn_imports;
  top.syn_all_scopes = [new_scope] ++ extend.syn_all_scopes ++ implement.syn_all_scopes ++ block.syn_all_scopes;
  top.syn_scopes = [new_scope];

  extend.inh_scope = top.inh_scope;

  implement.inh_scope = top.inh_scope;

  block.inh_scope = new_scope;

  -- ast printing
  top.pp = "decl_class(" ++ id.lexeme ++ ", " ++ extend.pp ++ ", " ++ implement.pp ++ ", " ++ block.pp ++ ")";
}

------------------------------------------------------------
---- Block
------------------------------------------------------------

abstract production block
top::Block ::= list::DeclList
{
  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  top.syn_all_scopes = list.syn_all_scopes;
  top.syn_scopes = list.syn_scopes;

  list.inh_scope = top.inh_scope;

  -- ast printing
  top.pp = "block(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

abstract production extendlist_list
top::Extend ::= list::QidList
{
  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  top.syn_all_scopes = list.syn_all_scopes;
  top.syn_scopes = list.syn_scopes;

  list.inh_scope = top.inh_scope;

  -- ast printing
  top.pp = "extendlist_list(" ++ list.pp ++ ")";
}

abstract production extendlist_nothing
top::Extend ::=
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- ast printing
  top.pp = "extendlist_nothing()";
}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

abstract production implementlist_list
top::Implement ::= list::QidList
{
  top.syn_decls = list.syn_decls;
  top.syn_refs = list.syn_refs;
  top.syn_imports = list.syn_imports;
  top.syn_all_scopes = list.syn_all_scopes;
  top.syn_scopes = list.syn_scopes;

  list.inh_scope = top.inh_scope;

  -- ast printing
  top.pp = "implementlist_list(" ++ list.pp ++ ")";
}

abstract production implementlist_nothing
top::Implement ::=
{
  top.syn_decls = [];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- ast printing
  top.pp = "implementlist_nothing()";
}

------------------------------------------------------------
---- Qid list
------------------------------------------------------------

abstract production qidlist_list
top::QidList ::= qid::Qid list::QidList
{
  top.syn_decls = qid.syn_decls ++ list.syn_decls;
  top.syn_refs = qid.syn_refs ++ list.syn_refs;
  top.syn_imports = qid.syn_imports ++ [qid.syn_iqid_import] ++ list.syn_imports; -- rqid followed by iqid in construction rules
  top.syn_all_scopes = qid.syn_all_scopes ++ list.syn_all_scopes;
  top.syn_scopes = qid.syn_scopes ++ list.syn_scopes; 

  qid.inh_scope = top.inh_scope;
  qid.inh_scope_two = top.inh_scope;

  list.inh_scope = top.inh_scope;

  -- ast printing
  top.pp = "qidlist_list(" ++ qid.pp ++ ", " ++ list.pp ++ ")";
}

abstract production qidlist_single
top::QidList ::= qid::Qid
{
  top.syn_decls = qid.syn_decls;
  top.syn_refs = qid.syn_refs;
  top.syn_imports = qid.syn_imports ++ [qid.syn_iqid_import]; -- rqid followed by iqid in construction rules
  top.syn_all_scopes = qid.syn_all_scopes;
  top.syn_scopes = qid.syn_scopes; 

  qid.inh_scope = top.inh_scope;
  qid.inh_scope_two = top.inh_scope;

  -- ast printing
  top.pp = "qidlist_single(" ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Qid
------------------------------------------------------------

abstract production qid_dot
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
  
  top.syn_decls = [];
  top.syn_refs = [init_usage];
  top.syn_imports = [];
  top.syn_all_scopes = [init_scope] ++ qid.syn_all_scopes;
  top.syn_scopes = []; 

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

  top.syn_decls = [];
  top.syn_refs = [init_import];
  top.syn_imports = [];
  top.syn_all_scopes = [];
  top.syn_scopes = [];

  -- ]]

  -- ast printing
  top.pp = "qid_single(" ++ id.lexeme ++ ")";

}

nonterminal IdDcl;
nonterminal IdRef;