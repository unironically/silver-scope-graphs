grammar scopegraph;


----------------
-- Scope Graph

synthesized attribute scope_list<a>::[Decorated Scope<a>];
synthesized attribute paths<a>::[Decorated Path<a>];
synthesized attribute all_decls<a>::[Decorated Declaration<a>];

nonterminal Graph<a> with scope_list<a>, paths<a>, all_decls<a>;

@{-
 - Constructing a graph node.
 -
 - @param scope_list The list of scopes the graph contains.
-}
abstract production cons_graph
top::Graph<a> ::= scope_list::[Decorated Scope<a>] 
  paths::[Decorated Path<a>]
{
  top.scope_list = scope_list;
  top.paths = paths;
  top.all_decls = foldl(
    (\all_decls::[Decorated Declaration<a>] scope::Decorated Scope<a> 
      -> all_decls ++ map((\pair::(String, Decorated Declaration<a>) -> snd(pair)), scope.declarations)), 
    [], scope_list);
}


----------------
-- Scopes

synthesized attribute id::Integer;
synthesized attribute parent<a>::Maybe<Decorated Scope<a>>;
synthesized attribute declarations<a>::[(String, Decorated Declaration<a>)]; -- pair of identifier name and node
synthesized attribute references<a>::[(String, Decorated Usage<a>)];
synthesized attribute imports<a>::[(String, Decorated Usage<a>)];
synthesized attribute to_string::String;

synthesized attribute child_scopes<a>::[Decorated Scope<a>];


nonterminal Scope<a> with id, parent<a>, declarations<a>, references<a>, imports<a>, to_string, child_scopes<a>;

@{-
 - Constructing a scope node.
 -
 - @param parent The scope node representing the lexically enclosing scope.
 - @param declarations The list of declarations attached to a node.
 - @param references The list of references attached to a node.
 - @param imports The list of imports attached to a node.
-}
abstract production cons_scope
top::Scope<a> ::= parent::Maybe<Decorated Scope<a>> 
  declarations::[(String, Decorated Declaration<a>)] 
  references::[(String, Decorated Usage<a>)] 
  imports::[(String, Decorated Usage<a>)]
  child_scopes::[Decorated Scope<a>]
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
synthesized attribute in_scope<a>::Decorated Scope<a>; -- Scope in which the declaration resides
synthesized attribute assoc_scope<a>::Maybe<Decorated Scope<a>>; -- Scope that this declaration points to (for imports)
synthesized attribute line::Integer;
synthesized attribute column::Integer;

nonterminal Declaration<a> with identifier, in_scope<a>, assoc_scope<a>, line, column, to_string;

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
top::Declaration<a> ::= identifier::String 
  in_scope::Decorated Scope<a> 
  assoc_scope::Maybe<Decorated Scope<a>> 
  line::Integer column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = line;
  top.column = column;
  top.to_string = top.identifier ++ "_" ++ toString(line) ++ "_" ++ toString(column);
}

abstract production cons_decl_ref
attribute line i occurs on a, attribute column i occurs on a =>
top::Declaration<a> ::= identifier::String 
  in_scope::Decorated Scope<a> 
  assoc_scope::Maybe<Decorated Scope<a>> 
  ast_node::Decorated a with i
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.to_string = top.identifier ++ "_" ++ toString(ast_node.line) ++ "_" ++ toString(ast_node.column);
}


----------------
-- Imports/References

synthesized attribute resolutions<a>::[Decorated Declaration<a>]; -- The node that this import points to with an invisible line. added to after resolution

nonterminal Usage<a> with identifier, in_scope<a>, resolutions<a>, line, column, to_string;

@{-
 - Constructing a usage (reference/import) node.
 -
 - @param identifier The scope node representing the lexically enclosing scope.
 - @param in_scope The scope node corresponding to the lexically enclosing scope of this usage.
 - @param line The line this usage was found on.
 - @param column The column this usage was found on.
-}
abstract production cons_usage
top::Usage<a> ::= identifier::String 
  in_scope::Decorated Scope<a> 
  line::Integer 
  column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.resolutions = resolve([], top);
  top.line = line;
  top.column = column;
  top.to_string = top.identifier ++ "_" ++ toString(line) ++ "_" ++ toString(column);
}
