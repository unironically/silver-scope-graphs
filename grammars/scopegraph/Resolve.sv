grammar scopegraph;

---------------
-- Resolution algorithm:

@{-
 - Resolves a reference to a set of declarations by first checking the immediate scope for
 - matching declarations, then all declarations visible through imports, then all those visible
 - by inheriting from the scope which is the parent of cur_scope.
 -
 - @param ref The usage whose declarations we are trying to resolve.
 - @param cur_scope The scope to search for valid declarations in.
 - @return A list of all declarations that ref resolves to.
-}
function resolve
[Decorated Declaration<d r>] ::= ref::Decorated Usage<d r> cur_scope::Decorated Scope<d r>
{
  -- Check for any matching declarations in the current scope
  local attribute decls::[Decorated Declaration<d r>] = 
    filter((\decl::Decorated Declaration<d r> -> decl.identifier == ref.identifier), cur_scope.declarations);

  -- Check any imports that exist, call resolve on them
  local attribute imps::[Decorated Declaration<d r>] = foldl(
    (\acc::[Decorated Declaration<d r>] cur::Decorated Declaration<d r> -> 
      case cur.assoc_scope of | nothing() -> [] | just(s) -> resolve(ref, s) end),
    [],
    foldl(
      (\acc::[Decorated Declaration<d r>] cur::Decorated Usage<d r> -> acc ++ cur.resolutions),
      [],
      filter((\imp::Decorated Usage<d r> -> imp.identifier != ref.identifier), cur_scope.imports)
    )
  );
  
  -- recursive call on parent
  local attribute par::[Decorated Declaration<d r>] = case cur_scope.parent of
    | nothing() -> []
    | just(p) -> resolve(ref, p) -- Cases of circularity? Already seen this scope - never ending reolution?
  end;
  
  return merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par));
}

@{-
 - Merges two lists of declarations such that the left-hand list shadows the right.
 -
 - @param left The left-hand list of declarations, which shadows the right.
 - @param right The shadowed right-hand list of declarations.
 - @return A list with all elements of the left and right lists, where the lefts shadows the rights.
-}
function merge_declarations_with_shadowing

[Decorated Declaration<a b>] ::= left::[Decorated Declaration<a b>] right::[Decorated Declaration<a b>]
{
  return unionBy(\mem_r::Decorated Declaration<a b> mem_l::Decorated Declaration<a b> -> 
    mem_r.identifier == mem_l.identifier, right , left);
}


----------------
-- Resolution paths:

nonterminal Path<a b> with start<a b>, final<a b>;

synthesized attribute start<a b>::Decorated Usage<a b>;
synthesized attribute final<a b>::Decorated Declaration<a b>;

@{-
 - Constructing a path node.
 -
 - @param start The usage being resolved in the path.
 - @param final The declaration resolved to in the path.
-}
abstract production cons_path
top::Path<a b> ::= start::Decorated Usage<a b> final::Decorated Declaration<a b>
{
  top.start = start;
  top.final = final;
}

@{-
 - Convert a list of resolution paths to a string.
 -
 - @param list The list of resolution paths.
 - @return A string representing all of the resolution paths.
-}
function string_paths
String ::= list::[Decorated Path<a b>]
{
  return case list of 
  | h::t -> "Found resolution: " ++ h.start.to_string ++ " --> " ++ h.final.to_string ++ "\n" ++ 
    string_paths(t)
  | [] -> ""
  end;
}
