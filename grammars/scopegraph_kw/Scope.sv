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
abstract production cons_graph
top::Graph<d r> ::= root_scope::Decorated Scope<d r> scope_list::[Decorated Scope<d r>] 
{
  top.root_scope = root_scope;
  top.scope_list = scope_list;
}


----------------
-- Scopes

synthesized attribute id::Integer;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute child_scopes<d r>::[Decorated Scope<d r>];

synthesized attribute declarations<d r>::[(String, d)];

synthesized attribute str::String;

nonterminal Scope<d r> with id, str, parent<d r>, declarations<d r>, child_scopes<d r>;

@{-
 - Constructing a scope node.
 -
 - @param parent The scope node representing the lexically enclosing scope.
 - @param declarations The list of declarations attached to a node.
 - @param references The list of references attached to a node.
 - @param imports The list of imports attached to a node.
 - @param assoc_decl In the case of the declarations from a scope being imported, this points to the declarations whose associated scope is this scope.
-}
abstract production cons_scope
top::Scope<d r> ::= 
  parent::Maybe<Decorated Scope<d r>> 
  declarations::[(String, d)]
  child_scopes::[Decorated Scope<d r>]
{
  top.id = genInt();
  top.parent = parent;
  top.declarations = declarations;
  top.str = toString(top.id);
  top.child_scopes = child_scopes;
}