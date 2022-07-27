grammar scopegraph;

------------------------------------------------------------
---- Utility functions
------------------------------------------------------------

@{-
 - Find a declaration node through searching by index.
 -
 - @param sought_index The declaration index to search for.
 - @param graph The scope graph to search in.
 - @return Either a declaration with a matching index, or nothing.
-}
function find_declaration_by_id
Maybe<Decorated Declaration> ::= 
  sought_index::String
  graph::Decorated Graph
{
  return let matching_decls::[Decorated Declaration] = 
    filter((\decl::Decorated Declaration -> decl.to_string == sought_index),
      foldl((\acc::[Decorated Declaration] scope::Decorated Scope -> acc ++ scope.declarations), 
        [], graph.scope_list))
  in if length(matching_decls) >= 1 then just(head(matching_decls)) else nothing() end; -- TODO: error checking on more than 1 matching decl
}

@{-
 - Find a list of references which resolve to a declaration.
 -
 - @param sought_decl The decoration our references should resolve to.
 - @param current_scope The scope to start looking in (initially, the scope sought_decl resides in).
 - @return A list of all references which resolve to decl.
-}
function find_all_references_for_decl
[Decorated Usage] ::=
  sought_decl::Decorated Declaration
  current_scope::Decorated Scope
{
  -- collect from current_scope
  local attribute immediate_refs::[Decorated Usage] = foldl(
    (\acc::[Decorated Usage] ref::Decorated Usage -> 
      acc ++ if ref.identifier == sought_decl.identifier then [ref] else []), 
    [], current_scope.references);

  -- collect from child scopes of current_scope
  local attribute child_scope_refs::[Decorated Usage] = foldl(
    (\acc::[Decorated Usage] child::Decorated Scope -> 
      acc ++ find_all_references_for_decl(sought_decl, child)),
    [], current_scope.child_scopes);

  -- get scopes that import current_scope
  local attribute parent_children::[Decorated Scope] = case current_scope.assoc_decl of
    | nothing() -> []
    | just(d) -> case current_scope.parent of
      | nothing() -> []
      | just(s) -> filter((\child::Decorated Scope -> foldl(
        (\acc::Boolean imp::Decorated Usage -> head(imp.resolutions).to_string == d.to_string), 
        false, child.imports)), s.child_scopes)
    end 
  end;

  local attribute importing_refs::[Decorated Usage] = foldl(
    (\acc::[Decorated Usage] scope::Decorated Scope -> acc ++ find_all_references_for_decl(sought_decl, scope)),
    [], parent_children);

  return if containsBy((\left::Decorated Declaration right::Decorated Declaration -> 
      left.identifier == right.identifier && left.to_string != right.to_string),
    sought_decl, current_scope.declarations) -- May need to change later for type-dependency of languages
  then []
  else immediate_refs ++ child_scope_refs ++ importing_refs;
}