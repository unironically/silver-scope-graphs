grammar scopegraph_kw;


----------------
-- Scope Graph

synthesized attribute scope_list<d r>::[Decorated Scope<d r>];
synthesized attribute root_scope<d r>::Decorated Scope<d r>;

nonterminal Graph<d r> with scope_list<d r>, root_scope<d r>;

@{-
 - Constructing a graph node.
 -
 - @param scope_list The list of scopes the graph contains.1

-}
abstract production mk_graph
top::Graph<d r> ::= root_scope::Decorated Scope<d r> scope_list::[Decorated Scope<d r>] 
{
  top.root_scope = root_scope;
  top.scope_list = scope_list;
}


----------------
-- Scopes

synthesized attribute id::Integer;
synthesized attribute scope_name::Maybe<String>;
synthesized attribute name::String;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute child_scopes<d r>::[Decorated Scope<d r>];

synthesized attribute decls<d r>::[Decorated d with {name}];

synthesized attribute str::String;

nonterminal Scope<d r> with id, scope_name, str, parent<d r>, decls<d r>, child_scopes<d r>;

@{-
 - Constructing a scope node.
 -
 - @param parent The scope node representing the lexically enclosing scope.
 - @param declarations The list of declarations attached to a node.
 - @param references The list of references attached to a node.
 - @param imports The list of imports attached to a node.
 - @param assoc_decl In the case of the declarations from a scope being imported, this points to the declarations whose associated scope is this scope.
-}

abstract production mk_scope
  attribute name i occurs on d =>
top::Scope<d r> ::= 
  parent::Maybe<Decorated Scope<d r>> 
  scope_name::Maybe<String>
  child_scopes::[Decorated Scope<d r>]
  decls::[Decorated d with i]
{
  top.id = genInt();
  top.scope_name = scope_name;
  top.parent = parent;
  top.decls = decls;
  top.str = toString(top.id);
  top.child_scopes = child_scopes;
}