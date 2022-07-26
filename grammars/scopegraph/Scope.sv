grammar scopegraph;


----------------
-- Scope Graph

synthesized attribute scope_list::[Decorated Scope];
--synthesized attribute paths::[Decorated Path];
synthesized attribute all_decls::[Decorated Declaration];
synthesized attribute errors::[Decorated Error];

nonterminal Graph with scope_list, all_decls, errors;

@{-
 - Constructing a graph node.
 -
 - @param scope_list The list of scopes the graph contains.
-}
abstract production cons_graph
top::Graph ::= scope_list::[Decorated Scope] 
  --paths::[Decorated Path]
{
  top.scope_list = scope_list;
  --top.paths = paths;
  top.all_decls = foldl(
    (\all_decls::[Decorated Declaration] scope::Decorated Scope 
      -> all_decls ++ scope.declarations), 
    [], scope_list);
  top.errors = foldl((\acc::[Decorated Error] scope::Decorated Scope -> acc ++ scope.errors), [], scope_list);
}


----------------
-- Scopes

synthesized attribute id::Integer;
synthesized attribute parent::Maybe<Decorated Scope>;
synthesized attribute declarations::[Decorated Declaration]; -- pair of identifier name and node
synthesized attribute references::[Decorated Usage];
synthesized attribute imports::[Decorated Usage];
synthesized attribute to_string::String;
synthesized attribute graphviz_name::String;

synthesized attribute child_scopes::[Decorated Scope];


nonterminal Scope with id, parent, declarations, references, imports, to_string, child_scopes, errors, graphviz_name;

@{-
 - Constructing a scope node.
 -
 - @param parent The scope node representing the lexically enclosing scope.
 - @param declarations The list of declarations attached to a node.
 - @param references The list of references attached to a node.
 - @param imports The list of imports attached to a node.
-}
abstract production cons_scope
top::Scope ::= parent::Maybe<Decorated Scope> 
  declarations::[Decorated Declaration] 
  references::[Decorated Usage] 
  imports::[Decorated Usage]
  child_scopes::[Decorated Scope]
{
  top.id = genInt();
  top.parent = parent;
  top.declarations = declarations;
  top.references = references;
  top.imports = imports;
  top.to_string = toString(top.id);
  top.graphviz_name = top.to_string;
  top.child_scopes = child_scopes;
  
  top.errors = foldl((\acc::[Decorated Error] ref::Decorated Usage -> acc ++ 
    if (length(ref.resolutions) < 1) then
      [decorate_nd_error(ref)]
    else if (length(ref.resolutions) > 1) then
      [decorate_md_error(ref, ref.resolutions)]
    else
      []
  ), [], references ++ imports);

}

function decorate_nd_error
Decorated Error ::= ref::Decorated Usage
{
  local attribute err::Error = no_declaration_found(ref);
  return err;
}

function decorate_md_error
Decorated Error ::= ref::Decorated Usage resolutions::[Decorated Declaration]
{
  local attribute err::Error = multiple_declarations_found(ref, resolutions);
  return err;
}


----------------
-- Declarations

synthesized attribute identifier::String; -- Name of the declaration
synthesized attribute in_scope::Decorated Scope; -- Scope in which the declaration resides
synthesized attribute assoc_scope::Maybe<Decorated Scope>; -- Scope that this declaration points to (for imports)
synthesized attribute line::Integer;
synthesized attribute column::Integer;

nonterminal Declaration with identifier, in_scope, assoc_scope, line, column, to_string, graphviz_name;

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
top::Declaration ::= identifier::String 
  in_scope::Decorated Scope 
  assoc_scope::Maybe<Decorated Scope> 
  line::Integer column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = line;
  top.column = column;
  top.to_string = top.identifier ++ "_[" ++ toString(line) ++ ", " ++ toString(column) ++ "]";
  top.graphviz_name = "\"" ++ top.to_string ++ "\"";
}

abstract production cons_decl_ref
attribute line i occurs on a, attribute column i occurs on a =>
top::Declaration ::= identifier::String 
  in_scope::Decorated Scope 
  assoc_scope::Maybe<Decorated Scope> 
  ast_node::Decorated a with i
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.to_string = top.identifier ++ "_[" ++ toString(ast_node.line) ++ ", " ++ toString(ast_node.column) ++ "]";
  top.graphviz_name = "\"" ++ top.to_string ++ "\"";
}


----------------
-- Imports/References

synthesized attribute resolutions::[Decorated Declaration]; -- The node that this import points to with an invisible line. added to after resolution

nonterminal Usage with identifier, in_scope, resolutions, line, column, to_string, graphviz_name;

@{-
 - Constructing a usage (reference/import) node.
 -
 - @param identifier The scope node representing the lexically enclosing scope.
 - @param in_scope The scope node corresponding to the lexically enclosing scope of this usage.
 - @param line The line this usage was found on.
 - @param column The column this usage was found on.
-}
abstract production cons_usage
top::Usage ::= identifier::String 
  in_scope::Decorated Scope 
  line::Integer 
  column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.resolutions = resolve(top, in_scope);
  top.line = line;
  top.column = column;
  top.to_string = top.identifier ++ "_[" ++ toString(line) ++ ", " ++ toString(column) ++ "]";
  top.graphviz_name = "\"" ++ top.to_string ++ "\"";
}
