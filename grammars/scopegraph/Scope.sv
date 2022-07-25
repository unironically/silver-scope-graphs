grammar scopegraph;


----------------
-- Scope Graph

synthesized attribute scope_list<d r>::[Decorated Scope<d r>];
synthesized attribute paths<d r>::[Decorated Path<d r>];
synthesized attribute all_decls<d r>::[Decorated Declaration<d r>];

nonterminal Graph<d r> with scope_list<d r>, paths<d r>, all_decls<d r>;

@{-
 - Constructing a graph node.
 -
 - @param scope_list The list of scopes the graph contains.
-}
abstract production cons_graph
top::Graph<d r> ::= scope_list::[Decorated Scope<d r>] 
  paths::[Decorated Path<d r>]
{
  top.scope_list = scope_list;
  top.paths = paths;
  top.all_decls = foldl(
    (\all_decls::[Decorated Declaration<d r>] scope::Decorated Scope<d r> 
      -> all_decls ++ map((\pair::(String, Decorated Declaration<d r>) -> snd(pair)), scope.declarations)), 
    [], scope_list);
}


----------------
-- Scopes

synthesized attribute id::Integer;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute declarations<d r>::[(String, Decorated Declaration<d r>)]; -- pair of identifier name and node
synthesized attribute references<d r>::[(String, Decorated Usage<d r>)];
synthesized attribute imports<d r>::[(String, Decorated Usage<d r>)];
synthesized attribute to_string::String;

synthesized attribute child_scopes<d r>::[Decorated Scope<d r>];


nonterminal Scope<d r> with id, parent<d r>, declarations<d r>, references<d r>, imports<d r>, to_string, child_scopes<d r>;

@{-
 - Constructing a scope node.
 -
 - @param parent The scope node representing the lexically enclosing scope.
 - @param declarations The list of declarations attached to a node.
 - @param references The list of references attached to a node.
 - @param imports The list of imports attached to a node.
-}
abstract production cons_scope
top::Scope<d r> ::= parent::Maybe<Decorated Scope<d r>> 
  declarations::[(String, Decorated Declaration<d r>)] 
  references::[(String, Decorated Usage<d r>)] 
  imports::[(String, Decorated Usage<d r>)]
  child_scopes::[Decorated Scope<d r>]
{
  top.id = genInt();
  top.parent = parent;
  top.declarations = declarations;
  top.references = references;
  top.imports = imports;
  top.to_string = toString(top.id);
  top.child_scopes = child_scopes;
}


----------------
-- Declarations

synthesized attribute identifier::String; -- Name of the declaration
synthesized attribute in_scope<d r>::Decorated Scope<d r>; -- Scope in which the declaration resides
synthesized attribute assoc_scope<d r>::Maybe<Decorated Scope<d r>>; -- Scope that this declaration points to (for imports)
synthesized attribute line::Integer;
synthesized attribute column::Integer;


nonterminal Declaration<d r> with identifier, in_scope<d r>, assoc_scope<d r>, line, column, to_string;

@{-
 - Constructing a declaration node.
 -
 - @param identifier The scope node representing the lexically enclosing scope.
 - @param in_scope The scope node corresponding to the lexically enclosing scope of this declaration.
 - @param assoc_scope The scope this node points to in the case of imports.
 - @param line The line this declaration was found on.
 - @param column The column this declaration was found on.
-}
abstract production cons_decl
top::Declaration<d r> ::= identifier::String 
  in_scope::Decorated Scope<d r> 
  assoc_scope::Maybe<Decorated Scope<d r>> 
  line::Integer column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = line;
  top.column = column;
  top.to_string = top.identifier ++ "_" ++ toString(line) ++ "_" ++ toString(column);
}


synthesized attribute name::String;

abstract production mk_dcl
  attribute name i occurs on d, 
  attribute line i occurs on d, 
  attribute column i occurs on d =>
top::Declaration<d r> ::= 
  ast_node::Decorated d with i
  in_scope::Decorated Scope<d r> 
  assoc_scope::Maybe<Decorated Scope<d r>> 
{
  top.identifier = ast_node.name;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.to_string = top.identifier ++ "_" ++ toString(ast_node.line) ++ "_" ++ toString(ast_node.column);
}


----------------
-- Imports/References

synthesized attribute resolutions<d r>::[Decorated Declaration<d r>]; -- The node that this import points to with an invisible line. added to after resolution

nonterminal Usage<d r> with identifier, in_scope<d r>, resolutions<d r>, line, column, to_string;

@{-
 - Constructing a usage (reference/import) node.
 -
 - @param identifier The scope node representing the lexically enclosing scope.
 - @param in_scope The scope node corresponding to the lexically enclosing scope of this usage.
 - @param line The line this usage was found on.
 - @param column The column this usage was found on.
-}
abstract production cons_usage
top::Usage<d r> ::= identifier::String 
  in_scope::Decorated Scope<d r> 
  line::Integer 
  column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.resolutions = resolve(top, in_scope);
  top.line = line;
  top.column = column;
  top.to_string = top.identifier ++ "_" ++ toString(line) ++ "_" ++ toString(column);
}



abstract production mk_ref
  attribute name i occurs on r, 
  attribute line i occurs on r, 
  attribute column i occurs on r =>
top::Usage<d r> ::= 
  in_scope::Decorated Scope<d r> 
  assoc_scope::Maybe<Decorated Scope<d r>> 
  ast_node::Decorated r with i
{
  top.identifier = ast_node.name;
  top.in_scope = in_scope;
  top.resolutions = resolve(top, in_scope);

  top.line = ast_node.line;
  top.column = ast_node.column;
  top.to_string = top.identifier ++ "_" ++ toString(ast_node.line) ++ "_" ++ toString(ast_node.column);
}
