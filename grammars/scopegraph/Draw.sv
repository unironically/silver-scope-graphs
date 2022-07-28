grammar scopegraph;


----------------
-- Scope graph:

@{-
 - Draw a scope graph in graphviz.
 -
 - @param graph The scope graph to draw.
 - @param draw_paths Indicates whether to draw the resolution paths into the graph.
 - @return The string with which graphviz will draw a graph.
-}
function graphviz_draw_graph
String ::= graph::Decorated Graph<d r> draw_paths::Boolean draw_parents::Boolean
{
  return "digraph {{ node [shape=circle style=solid fontsize=12] " ++ 
    foldl((\acc::String scope::Decorated Scope<d r> 
      -> acc ++ " " ++ toString(scope.id)), "", graph.scope_list) ++ 
    "} node [shape=box fontsize=12] edge [arrowhead=normal] " ++ 
    (if draw_paths then graphviz_draw_paths(graph) else "") ++
    graphviz_scopes(graph.scope_list) ++ 
    (if draw_parents then graphviz_scope_children(graph.scope_list) else "") ++ "}";
}

@{-
 - Collect information to draw a list of scopes in graphviz.
 -
 - @param scopes The list of scopes to draw.
 - @return The graphviz string representing the list of scopes.
-}
function graphviz_scopes
String ::= scopes::[Decorated Scope<d r>]
{
  return case scopes of 
    | [] -> ""
    | h::t -> 
      h.graphviz_name ++ (case h.parent of | nothing() 
        -> "" | just(p) -> " -> " ++ p.graphviz_name end) ++ " " ++ 
      graphviz_scope_refs(h, h.references) ++ 
      graphviz_scope_decls(h, h.declarations) ++ 
      "{edge [arrowhead=onormal] " ++ graphviz_scope_imports(h, h.imports) ++ "}" ++
      graphviz_scopes(t)
  end;
}

@{-
 - Collect information to draw a list of references in graphviz.
 -
 - @param scopes The list of references to draw.
 - @return The graphviz string representing the list of references.
-}
function graphviz_scope_refs
String ::= scope::Decorated Scope<d r> refs::[Decorated Usage<d r>]
{
  return case refs of 
    | [] -> ""
    | h::t -> h.graphviz_name ++ " -> " ++ scope.graphviz_name ++ " " ++ graphviz_scope_refs(scope, t)
  end;
}

@{-
 - Collect information to draw a list of imports in graphviz.
 -
 - @param scopes The list of imports to draw.
 - @return The graphviz string representing the list of imports.
-}
function graphviz_scope_imports
String ::= scope::Decorated Scope<d r> refs::[Decorated Usage<d r>]
{
  return case refs of 
    | [] -> ""
    | h::t -> scope.graphviz_name ++ " -> " ++ h.graphviz_name ++ " " ++ graphviz_scope_imports(scope, t)
  end;
}

@{-
 - Collect information to draw a list of declarations in graphviz.
 -
 - @param scopes The list of declarations to draw.
 - @return The graphviz string representing the list of declarations.
-}
function graphviz_scope_decls
String ::= scope::Decorated Scope<d r> decls::[Decorated Declaration<d r>]
{
  return case decls of 
    | [] -> ""
    | h::t -> 
      scope.graphviz_name ++ " -> " ++ h.graphviz_name ++ " " ++ 
      (case h.assoc_scope of 
        | nothing() -> "" 
        | just(s) -> "{ edge [arrowhead=onormal]" ++ h.graphviz_name ++ " -> " ++ s.graphviz_name ++ "} " 
      end) ++ 
      graphviz_scope_decls(scope, t)
  end;
}

@{-
 - Collect information to draw a list of scope children edges.
 -
 - @param scopes The list of child edges to draw.
 - @return The graphviz string representing the list of child edges.
-}
function graphviz_scope_children
String ::= scopes::[Decorated Scope<d r>]
{
  return "{edge [color=pink style=dashed] " ++
    foldl((\accone::String h::Decorated Scope<d r> ->
    accone ++ (foldl(
      (\acc::String child::Decorated Scope<d r> -> acc ++ " " ++ h.to_string ++ " -> "  ++ child.to_string),
      "",
      h.child_scopes
    ))), "", scopes) ++ "}";
}

@{-
 - Draw resolution paths in graphviz.
 -
 - @param graph The graph to draw resolution edges for.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_draw_paths
String ::= graph::Decorated Graph<d r>
{
  return let all::([Decorated Usage<d r>], [Decorated Usage<d r>]) = 
    foldl(
      (\acc::([Decorated Usage<d r>], [Decorated Usage<d r>]) cur_scope::Decorated Scope<d r> -> 
        let new_pair::([Decorated Usage<d r>], [Decorated Usage<d r>]) = 
          partition((\usg::Decorated Usage<d r> -> length(usg.resolutions) == 1), 
            cur_scope.references ++ cur_scope.imports) 
        in 
          (fst(acc) ++ fst(new_pair), snd(acc) ++ snd(new_pair))
        end),
      ([],[]),
      graph.scope_list)
  in
    "{edge [arrowhead=normal color=blue style=dashed]" ++ 
      graphviz_draw_individual_paths(fst(all)) ++ "}" ++
    "{node [color=red shape=box fontsize=12] edge [arrowhead=normal color=red style=dashed]" ++
      graphviz_draw_individual_paths(snd(all)) ++ "}"
  end ++ "\n";
}

@{-
 - Draw paths for a list of references in graphviz.
 -
 - @param graph The references to draw resolution edges for.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_draw_individual_paths
String ::= usages::[Decorated Usage<d r>]
{
  return foldl(
    (\acc::String usg::Decorated Usage<d r> -> acc ++ " " ++ usg.graphviz_name ++ " " ++ 
      foldl((\acc::String decl::Decorated Declaration<d r> -> acc ++ " " ++ usg.graphviz_name ++ 
          " -> " ++ decl.graphviz_name), 
        "", 
        usg.resolutions)),
    "", 
    nubBy((\left::Decorated Usage<d r> right::Decorated Usage<d r> -> left.to_string == right.to_string), 
      usages));
}

