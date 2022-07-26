grammar minijava;

imports scopegraph;


nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Block;
nonterminal Extend;
nonterminal Implement;
nonterminal QidList;
nonterminal Qid;

-- Types used in scope graphs for this language example
type Graph_type = Graph;
type Scope_type = Scope;
type Decl_type = Declaration;
type Usage_type = Usage;
type Error_type = Error;
type Path_type = Path;

-- Printing AST term
synthesized attribute pp::String occurs on Program, DeclList, Decl, Block, Extend, Implement, QidList, Qid;

-- Information required for constructing scope nodes with references, declarations and imports
-- Sub-expressions can synthesize each of these, which must be given to the enclosing scope
synthesized attribute syn_decls::[Decorated Decl_type] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;
synthesized attribute syn_refs::[Decorated Usage_type] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;
synthesized attribute syn_imports::[Decorated Usage_type] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;

-- Information required for synthesizing a graph node at the root of an AST
synthesized attribute syn_graph::Decorated Graph_type occurs on Program;
synthesized attribute syn_all_scopes::[Decorated Scope_type] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;

-- The inherited scope passed to a node is the scope in which the corresponding construct resides
inherited attribute inh_scope::Decorated Scope_type occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;
  inherited attribute inh_scope_two::Decorated Scope_type occurs on Qid;

-- For double-edged arrow between parent and child scopes
synthesized attribute syn_scopes::[Decorated Scope_type] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid;

-- The import synthesized in the "iqid" construct of the scope graph construction algorithm for this language example
synthesized attribute syn_iqid_import::Decorated Usage_type occurs on Qid;

------------------------------------------------------------
---- Program
------------------------------------------------------------

abstract production prog
top::Program ::= list::DeclList
{

  -- The root scope of the program
  local attribute init_scope::Scope_type = cons_scope(
    nothing(),
    list.syn_decls,
    list.syn_refs,
    list.syn_imports,
    list.syn_scopes
  );

  local attribute init_graph::Graph_type = cons_graph(init_scope::list.syn_all_scopes);
  top.syn_graph = init_graph; -- simply substituting cons_graph(...) here does not work

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
  local attribute new_scope::Scope_type = cons_scope(
    just(top.inh_scope),
    extend.syn_decls ++ implement.syn_decls ++ block.syn_decls,
    extend.syn_refs ++ implement.syn_refs ++ block.syn_refs,
    extend.syn_refs ++ implement.syn_refs ++ block.syn_refs,
    extend.syn_scopes ++ implement.syn_scopes ++ block.syn_scopes
  );

  local attribute init_decl::Decl_type = cons_decl(
    id.lexeme,
    top.inh_scope,
    just(new_scope),
    id.line,
    id.column
  );

  top.syn_decls = [init_decl];
  top.syn_refs = [];
  top.syn_imports = [];
  top.syn_all_scopes = [new_scope] ++ extend.syn_all_scopes ++ implement.syn_all_scopes ++ block.syn_all_scopes;
  top.syn_scopes = [new_scope];

  extend.inh_scope = new_scope;

  implement.inh_scope = new_scope;

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
  top.syn_scopes = qid.syn_scopes ++ list.syn_scopes; -- ADD

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
  top.syn_scopes = qid.syn_scopes; -- ADD

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
  local attribute init_usage::Usage_type = cons_usage ( -- rqid
    id.lexeme,
    top.inh_scope,
    id.line,
    id.column
  );

  local attribute init_scope::Scope_type = cons_scope (
    nothing(),
    qid.syn_decls,
    qid.syn_refs,
    qid.syn_imports ++ [init_usage],
    qid.syn_scopes -- ADD
  );

  top.syn_decls = [];
  top.syn_refs = [init_usage];
  top.syn_imports = [];
  top.syn_all_scopes = [init_scope] ++ qid.syn_all_scopes;
  top.syn_iqid_import = qid.syn_iqid_import;
  top.syn_scopes = []; -- ADD
  
  qid.inh_scope = init_scope;
  qid.inh_scope_two = top.inh_scope_two;
  
  -- ast printing
  top.pp = "qid_dot(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  local attribute init_import_two::Usage_type = cons_usage (
    id.lexeme,
    top.inh_scope_two,
    id.line,
    id.column
  );

  local attribute init_import::Usage_type = cons_usage (
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

  --local attribute fst_path::Path_type = cons_path(init_import, head(init_import.resolutions)); -- TODO: in case of errors print some paths anyway
  --top.paths = [fst_path];

  -- ast printing
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
}