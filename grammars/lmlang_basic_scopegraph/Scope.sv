grammar lmlang_basic_scopegraph;

nonterminal Graph with sg_root_scopes;
nonterminal Scope with id, str, sg_parent, sg_decls, sg_refs, sg_imps;
nonterminal Decl with str, name, line, column, sg_in_scope, sg_assoc_scope;
nonterminal Ref with str, name, line, column, sg_in_scope;

synthesized attribute id::Integer;
synthesized attribute str::String;
synthesized attribute name::String;
synthesized attribute line::Integer;
synthesized attribute column::Integer;

synthesized attribute sg_parent::Maybe<Scope>;
synthesized attribute sg_in_scope::Scope;
synthesized attribute sg_assoc_scope::Maybe<Scope>;
synthesized attribute sg_root_scopes::[Decorated Scope];

synthesized attribute sg_ast_decl::Decorated lm:IdDecl occurs on Decl;
synthesized attribute sg_ast_ref::lm:IdRef occurs on Ref;

synthesized attribute sg_decls::[Decorated Decl];
synthesized attribute sg_refs::[Ref];
synthesized attribute sg_imps::[Ref];

--------------------
-- Graph

abstract production mk_graph
top::Graph ::=
  root_scopes::[Decorated Scope]
{
  top.sg_root_scopes = root_scopes;
}

--------------------
-- Scope nodes

abstract production mk_scope
top::Scope ::= 
  parent::Maybe<Scope>
  decls::[Decorated Decl]
  refs::[Ref]
  imps::[Ref]
{
  top.id = genInt();
  top.sg_parent = parent;
  top.sg_decls = decls;
  top.sg_refs = refs;
  top.sg_imps = imps;  
  top.str = toString(top.id);
}

abstract production mk_scope_orphan
top::Scope ::= 
  decls::[Decorated Decl]
  refs::[Ref]
  imps::[Ref]
{ forwards to mk_scope(nothing(), decls, refs, imps); }

--------------------
-- Declaration nodes

abstract production mk_decl
top::Decl ::= 
  in_scope::Scope
  assoc_scope::Maybe<Scope>
  ast_node::Decorated lm:IdDecl
{
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.name = ast_node.name;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.sg_in_scope = in_scope;
  top.sg_assoc_scope = assoc_scope;
  top.sg_ast_decl = ast_node;
}

--------------------
-- Reference nodes

abstract production mk_ref
top::Ref ::=
  in_scope::Scope
  ast_node::lm:IdRef
{
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.name = ast_node.name;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.sg_in_scope = in_scope;
  top.sg_ast_ref = ast_node;
}