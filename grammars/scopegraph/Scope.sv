grammar scopegraph;


----------------
-- Scope Graph

synthesized attribute scope_list<d r>::[Decorated Scope<d r>];
synthesized attribute root_scope<d r>::Decorated Scope<d r>;
synthesized attribute paths<d r>::[Decorated Path<d r>];
synthesized attribute all_decls<d r>::[Decorated Decl<d r>];
synthesized attribute errors<d r>::[Decorated Error<d r>];

nonterminal Graph<d r> with scope_list<d r>, root_scope<d r>, all_decls<d r>, errors<d r>, paths<d r>;

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
  top.all_decls = foldl(
    (\all_decls::[Decorated Decl<d r>] scope::Decorated Scope<d r> 
      -> all_decls ++ scope.declarations), 
    [], scope_list);
  top.errors = foldl((\acc::[Decorated Error<d r>] scope::Decorated Scope<d r> -> 
    acc ++ scope.errors), [], scope_list);
  top.paths = foldl((\acc::[Decorated Path<d r>] scope::Decorated Scope<d r> -> 
    acc ++ scope.paths), [], scope_list);
}


----------------
-- Scopes

synthesized attribute id::Integer;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute declarations<d r>::[Decorated Decl<d r>];
synthesized attribute references<d r>::[Decorated Ref<d r>];
synthesized attribute imports<d r>::[Decorated Ref<d r>];
inherited attribute assigned_id::String;

synthesized attribute str::String;
synthesized attribute delimited::String;
synthesized attribute child_scopes<d r>::[Decorated Scope<d r>];
synthesized attribute assoc_decl<d r>::Maybe<Decorated Decl<d r>>;

nonterminal Scope<d r> with id, parent<d r>, declarations<d r>, references<d r>, imports<d r>, str, child_scopes<d r>, assoc_decl<d r>, errors<d r>, paths<d r>, assigned_id;

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
top::Scope<d r> ::= parent::Maybe<Decorated Scope<d r>> 
  declarations::[Decorated Decl<d r>] 
  references::[Decorated Ref<d r>] 
  imports::[Decorated Ref<d r>]
  child_scopes::[Decorated Scope<d r>]
  assoc_decl::Maybe<Decorated Decl<d r>>
{
  top.id = genInt();
  top.parent = parent;
  top.declarations = declarations;
  top.references = references;
  top.imports = imports;
  top.child_scopes = child_scopes;
  top.str = toString(top.id);
  top.assoc_decl = assoc_decl;
  top.errors = foldl((\acc::[Decorated Error<d r>] ref::Decorated Ref<d r> -> 
    acc ++ ref.errors), [], references ++ imports);
  top.paths = foldl((\acc::[Decorated Path<d r>] ref::Decorated Ref<d r> -> 
    acc ++ ref.paths), [], references ++ imports);
}

function decorate_nd_error
Decorated Error<d r> ::= ref::Decorated Ref<d r>
{
  local attribute err::Error<d r> = no_declaration_found(ref);
  return err;
}

function decorate_md_error
Decorated Error<d r> ::= ref::Decorated Ref<d r> resolutions::[Decorated Decl<d r>]
{
  local attribute err::Error<d r> = multiple_declarations_found(ref, resolutions);
  return err;
}

function decorate_cons_path
Decorated Path<d r> ::= ref::Decorated Ref<d r> dcl::Decorated Decl<d r>
{
  local attribute path::Path<d r> = cons_path(ref, dcl);
  return path;
}


----------------
-- Decls

synthesized attribute identifier::String; -- Name of the declaration

synthesized attribute in_scope<d r>::Decorated Scope<d r>; -- Scope in which the declaration resides
synthesized attribute assoc_scope<d r>::Maybe<Decorated Scope<d r>>; -- Scope that this declaration points to (for imports)
synthesized attribute line::Integer;
synthesized attribute column::Integer;


nonterminal Decl<d r> with identifier, in_scope<d r>, assoc_scope<d r>, line, column, str;

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
top::Decl<d r> ::= identifier::String 
  in_scope::Decorated Scope<d r> 
  assoc_scope::Maybe<Decorated Scope<d r>> 
  line::Integer column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = line;
  top.column = column;
  top.str = top.identifier ++ "_" ++ toString(line) ++ "_" ++ toString(column);
}

synthesized attribute name::String;

abstract production mk_dcl
  attribute name i occurs on d, 
  attribute line i occurs on d, 
  attribute column i occurs on d =>
top::Decl<d r> ::= 
  ast_node::Decorated d with i
  in_scope::Decorated Scope<d r> 
  assoc_scope::Maybe<Decorated Scope<d r>> 
{
  top.identifier = ast_node.name;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.str = top.identifier ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
}


----------------
-- Imports/References

synthesized attribute resolutions<d r>::[Decorated Decl<d r>]; -- The node that this import points to with an invisible line. added to after resolution

inherited attribute seen_imports<d r>::[Decorated Ref<d r>];

nonterminal Ref<d r> with identifier, in_scope<d r>, resolutions<d r>, line, column, str, paths<d r>, errors<d r>, seen_imports<d r>;

@{-
 - Constructing a usage (reference/import) node.
 -
 - @param identifier The scope node representing the lexically enclosing scope.
 - @param in_scope The scope node corresponding to the lexically enclosing scope of this usage.
 - @param line The line this usage was found on.
 - @param column The column this usage was found on.
-}
abstract production cons_usage
top::Ref<d r> ::= 
  identifier::String 
  in_scope::Decorated Scope<d r> 
  line::Integer 
  column::Integer
{
  top.identifier = identifier;
  top.in_scope = in_scope;
  
  top.resolutions = let done::(String, [Decorated Decl<d r>]) = resolve([], top, "") in unsafeTrace(snd(done), printT("-- New top-level resolution for " ++ top.str ++ ":\n" ++ fst(done), unsafeIO())) end;
  --top.resolutions = resolve_new(top, top.in_scope, [], top.seen_imports);

  top.line = line;
  top.column = column;
  top.str = top.identifier ++ "_" ++ toString(line) ++ "_" ++ toString(column);

  top.paths = foldl((\acc::[Decorated Path<d r>] dcl::Decorated Decl<d r> -> 
    acc ++ [decorate_cons_path(top, dcl)]), [], top.resolutions);
  
  top.errors = if (length(top.resolutions) > 1) then
    [decorate_md_error(top, top.resolutions)]
  else if (length(top.resolutions) <= 0) then
    [decorate_nd_error(top)]
  else
    [];
}


abstract production mk_ref
  attribute name i occurs on r, 
  attribute line i occurs on r, 
  attribute column i occurs on r =>
top::Ref<d r> ::= 
  ast_node::Decorated r with i
  in_scope::Decorated Scope<d r> 
{
  top.identifier = ast_node.name;
  top.in_scope = in_scope;
  top.resolutions = let done::(String, [Decorated Decl<d r>]) = resolve([], top, "") in unsafeTrace(snd(done), printT("-- New top-level resolution for " ++ top.str ++ ":\n" ++ fst(done), unsafeIO())) end; -- Visser algorithm
  --top.resolutions = resolve_new(top, in_scope); -- luke algorithm

  top.line = ast_node.line;
  top.column = ast_node.column;
  top.str = top.identifier ++ "_" ++ toString(ast_node.line) ++ "_" ++ toString(ast_node.column);

  top.paths = foldl((\acc::[Decorated Path<d r>] dcl::Decorated Decl<d r> -> 
    acc ++ [decorate_cons_path(top, dcl)]), [], top.resolutions);

  top.errors = if (length(top.resolutions) > 1) then
    [decorate_md_error(top, top.resolutions)]
  else if (length(top.resolutions) <= 0) then
    [decorate_nd_error(top)]
  else
    [];
}