grammar minijava;

imports scopegraph_kw as sg;


nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Block;
nonterminal Extend;
nonterminal Implement;
nonterminal QidList;
nonterminal Qid;
nonterminal Expression;
nonterminal Type;
nonterminal IdDcl;
nonterminal IdRef;

-- Printing AST term
synthesized attribute pp::String occurs on Program, DeclList, Decl, Block, Extend, Implement, 
  QidList, Qid, Expression, Type, IdDcl, IdRef;

monoid attribute decls::[Decorated IdDcl] occurs on DeclList, Decl, Block, Extend, Implement, 
  QidList, Qid, Expression, Type, IdDcl, IdRef;

-- Every scope in a scope graph
monoid attribute all_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid, Expression, Type, IdDcl, IdRef;

-- Scopes passed up to a parent scope
monoid attribute child_scopes::[Decorated sg:Scope<IdDcl IdRef>] occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid, Expression, Type, IdDcl, IdRef;

-- Scopes passed down as the parent of new scopes
inherited attribute parent_scope::Decorated sg:Scope<IdDcl IdRef> occurs on DeclList, Decl, Block, 
  Extend, Implement, QidList, Qid, Expression, Type, IdDcl, IdRef;

-- Entire graph synthesized by root
synthesized attribute scope_graph::Decorated sg:Graph<IdDcl IdRef> occurs on Program;

-- Identifier for references and declarations
--synthesized attribute name::String occurs on IdDcl, IdRef;
attribute sg:name occurs on IdDcl, IdRef;

-- Specify flowtype - this seems to be required by the type system
-- This is done for each nonterminal, so object languages can decide
-- what this is for their nonterminals. This is good.
-- Also, defining it on `name` removes the ambiguity so that we do not
-- need the definition for `line` or `column`.
flowtype sg:name {} on IdDcl, IdRef;

------------------------------------------------------------
---- Program
------------------------------------------------------------

abstract production prog
top::Program ::= list::DeclList
{
  -- scope graph
  local attribute scope_graph::sg:Graph<IdDcl IdRef> = sg:mk_graph(
    global_scope,
    global_scope::list.all_scopes
  );

  -- global scope
  local attribute global_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope(
    nothing(),
    nothing(),
    list.child_scopes,
    list.decls
  );

  top.scope_graph = scope_graph;

  list.parent_scope = global_scope;

  -- ast printing
  top.pp = "prog(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- Declarations
------------------------------------------------------------

abstract production decl_class
top::Decl ::= dcl::IdDcl extend::Extend implement::Implement block::Block
{
  -- Scope for this class
  local attribute class_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope(
    just(top.parent_scope),
    just(dcl.sg:name),
    block.child_scopes,
    block.decls
  );

  top.decls := [dcl];
  top.child_scopes := [class_scope];
  top.all_scopes := class_scope::block.all_scopes;

  extend.parent_scope = class_scope;

  implement.parent_scope = class_scope;
  
  block.parent_scope = class_scope;

  -- ast printing
  top.pp = "decl_class(" ++ dcl.pp ++ ", " ++ extend.pp ++ ", " ++ implement.pp ++ ", " ++ block.pp ++ ")";
}

abstract production decl_vardecl
top::Decl ::= type::Type dcl::IdDcl
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "decl_vardecl(" ++ type.pp ++ ", " ++ dcl.pp ++ ")";
}

abstract production decl_method
top::Decl ::= type::Type dcl::IdDcl block::Block
{
  -- Scope for this method
  local attribute method_scope::sg:Scope<IdDcl IdRef> = sg:mk_scope(
    just(top.parent_scope),
    just(dcl.sg:name),
    block.child_scopes,
    block.decls
  );

  top.decls := [dcl];
  top.child_scopes := [method_scope];
  top.all_scopes := method_scope::block.all_scopes; -- not necessary to use all_scopes *unless* methods can create sub-scopes

  block.parent_scope = method_scope;

  -- ast printing
  top.pp = "decl_method(" ++ type.pp ++ ", " ++ dcl.pp ++ ", " ++ block.pp ++ ")";
}

abstract production decl_expr
top::Decl ::= expr::Expression
{
  propagate decls, all_scopes, child_scopes, parent_scope;
  
  -- ast printing
  top.pp = "decl_expr(" ++ expr.pp ++ ")";
}

------------------------------------------------------------
---- Block
------------------------------------------------------------

abstract production block
top::Block ::= list::DeclList
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "block(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- Expression
------------------------------------------------------------

abstract production expr_qid
top::Expression ::= qid::Qid
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "expr_qid(" ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Types
------------------------------------------------------------

abstract production type_int
top::Type ::=
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "type_int()";
}

------------------------------------------------------------
---- Extend
------------------------------------------------------------

abstract production extendlist_list
top::Extend ::= list::QidList
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "extendlist_list(" ++ list.pp ++ ")";
}

abstract production extendlist_nothing
top::Extend ::=
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "extendlist_nothing()";
}

------------------------------------------------------------
---- Implement
------------------------------------------------------------

abstract production implementlist_list
top::Implement ::= list::QidList
{
  propagate decls, all_scopes, child_scopes, parent_scope;
  
  -- ast printing
  top.pp = "implementlist_list(" ++ list.pp ++ ")";
}

abstract production implementlist_nothing
top::Implement ::=
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "implementlist_nothing()";
}

------------------------------------------------------------
---- Qid list
------------------------------------------------------------

abstract production qidlist_list
top::QidList ::= qid::Qid list::QidList
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "qidlist_list(" ++ qid.pp ++ ", " ++ list.pp ++ ")";
}

abstract production qidlist_single
top::QidList ::= qid::Qid
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "qidlist_single(" ++ qid.pp ++ ")";
}

------------------------------------------------------------
---- Qid
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= dcl::IdRef qid::Qid
{
  propagate decls, all_scopes, child_scopes, parent_scope;
  
  -- ast printing
  top.pp = "qid_list(" ++ dcl.pp ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= dcl::IdRef
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  -- ast printing
  top.pp = "qid_single(" ++ dcl.pp ++ ")";
}

------------------------------------------------------------
---- IdRef / IdDecl
------------------------------------------------------------

abstract production idref
top::IdRef ::= id::ID_t
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  top.sg:name = id.lexeme;

  -- ast printing
  top.pp = "idref(" ++ id.lexeme ++ ")";
}

abstract production iddcl
top::IdDcl ::= id::ID_t
{
  propagate decls, all_scopes, child_scopes, parent_scope;

  top.sg:name = id.lexeme;

  -- ast printing
  top.pp = "iddcl(" ++ id.lexeme ++ ")";
}