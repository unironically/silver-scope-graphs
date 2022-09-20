grammar scopetree;

nonterminal Graph<d r> with root_nodes<d r>;
nonterminal Scope<d r> with id, str, parent<d r>, children<d r>;

synthesized attribute id::Integer;
synthesized attribute str::String;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute children<d r>::[Decorated Scope<d r>];
synthesized attribute root_nodes<d r>::[Decorated Scope<d r>];

synthesized attribute name::String;
synthesized attribute line::Integer;
synthesized attribute column::Integer;

--------------------
-- Graph

abstract production mk_graph
top::Graph<d r> ::=
  root_nodes::[Decorated Scope<d r>]
{
  top.root_nodes = root_nodes;
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
top::Scope<d r> ::= parent::Maybe<Decorated Scope<d r>>
{ forwards to mk_scope(parent, []); }

abstract production mk_scope_parentless
top::Scope<d r> ::= children::[Decorated Scope<d r>]
{ forwards to mk_scope(nothing(), children); }

abstract production mk_scope_disconnected
top::Scope<d r> ::=
{ forwards to mk_scope(nothing(), []); }

--------------------
-- Declaration nodes