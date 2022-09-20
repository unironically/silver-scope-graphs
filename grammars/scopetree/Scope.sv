grammar scopetree;

nonterminal Graph<d r> with root_scopes<d r>;
nonterminal Scope<d r> with id, str, parent<d r>, children<d r>;
nonterminal Decl<d r> with str, name, line, column, in_scope<d r>, assoc_scope<d r>;
nonterminal Ref<d r> with str, name, line, column, in_scope<d r>;

synthesized attribute id::Integer;
synthesized attribute str::String;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute children<d r>::[Decorated Scope<d r>];
synthesized attribute root_scopes<d r>::[Decorated Scope<d r>];
synthesized attribute in_scope<d r>::Decorated Scope<d r>;
synthesized attribute assoc_scope<d r>::Maybe<Decorated Scope<d r>>;

synthesized attribute name::String;
synthesized attribute line::Integer;
synthesized attribute column::Integer;

--------------------
-- Graph

abstract production mk_graph
top::Graph<d r> ::=
  root_scopes::[Decorated Scope<d r>]
{
  top.root_scopes = root_scopes;
}

--------------------
-- Scope nodes

abstract production mk_scope
top::Scope<d r> ::= 
  parent::Maybe<Decorated Scope<d r>>
  children::[Decorated Scope<d r>]
{
  top.id = genInt();
  top.parent = parent;
  top.children = children;
  top.str = toString(top.id);
}

abstract production mk_scope_childless
top::Scope<d r> ::= 
  parent::Maybe<Decorated Scope<d r>>
{ forwards to mk_scope(parent, []); }

abstract production mk_scope_parentless
top::Scope<d r> ::= 
  children::[Decorated Scope<d r>]
{ forwards to mk_scope(nothing(), children); }

abstract production mk_scope_disconnected
top::Scope<d r> ::=
{ forwards to mk_scope(nothing(), []); }

--------------------
-- Declaration nodes

abstract production mk_decl
  attribute name i occurs on d,
  attribute line i occurs on d,
  attribute column i occurs on d =>
top::Decl<d r> ::= 
  ast_node::Decorated d with i
  in_scope::Decorated Scope<d r>
{
  forwards to mk_decl_assoc(ast_node, in_scope, nothing());
}

abstract production mk_decl_assoc
  attribute name i occurs on d,
  attribute line i occurs on d,
  attribute column i occurs on d =>
top::Decl<d r> ::= 
  ast_node::Decorated d with i
  in_scope::Decorated Scope<d r>
  assoc_scope::Maybe<Decorated Scope<d r>>
{
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.name = ast_node.name;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
}

--------------------
-- Reference nodes

abstract production mk_ref
  attribute name i occurs on r,
  attribute line i occurs on r,
  attribute column i occurs on r =>
top::Ref<d r> ::=
  ast_node::Decorated r with i
  in_scope::Decorated Scope<d r>
{
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.name = ast_node.name;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.in_scope = in_scope;
}