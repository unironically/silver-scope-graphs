grammar scopegraph;


----------------
-- Resolution paths:

@{-
 - Draw resolution paths in graphviz.
 -
 - @param paths The list of paths to draw.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_draw_paths
String ::= paths::[Decorated Path<a>]
{
  return "digraph {" ++ 
    foldl((\acc::String path::Decorated Path<a> -> 
      acc ++ " " ++ path.start.to_string ++ " -> " ++ path.final.to_string), "", paths) ++ 
    "}";
}


----------------
-- Scope graph:

@{-
 - Draw a scope graph in graphviz.
 -
 - @param graph The scope graph to draw.
 - @return The string with which graphviz will draw a graph.
-}
function graphviz_draw_graph
String ::= graph::Decorated Graph<a>
{
  return "digraph {{ node [shape=circle fontsize=12] " ++ 
    foldl((\acc::String scope::Decorated Scope<a> 
      -> acc ++ " " ++ toString(scope.id)), "", graph.scope_list) ++ 
    "} node [shape=box fontsize=12] edge [arrowhead=normal] " ++ 
    graphviz_scopes(graph.scope_list) ++ "}";
}

@{-
 - Collect information to draw a list of scopes in graphviz.
 -
 - @param scopes The list of scopes to draw.
 - @return The graphviz string representing the list of scopes.
-}
function graphviz_scopes
String ::= scopes::[Decorated Scope<a>]
{
  return case scopes of 
    | [] -> ""
    | h::t -> 
      h.to_string ++ (case h.parent of | nothing() 
        -> "" | just(p) -> " -> " ++ p.to_string end) ++ " " ++ 
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
String ::= scope::Decorated Scope<a> refs::[(String, Decorated Usage<a>)]
{
  return case refs of 
    | [] -> ""
    | (h1, h2)::t -> h2.to_string ++ " -> " ++ scope.to_string ++ " " ++ 
      graphviz_scope_refs(scope, t)
  end;
}

@{-
 - Collect information to draw a list of imports in graphviz.
 -
 - @param scopes The list of imports to draw.
 - @return The graphviz string representing the list of imports.
-}
function graphviz_scope_imports
String ::= scope::Decorated Scope<a> refs::[(String, Decorated Usage<a>)]
{
  return case refs of 
    | [] -> ""
    | (h1, h2)::t -> scope.to_string ++ " -> " ++ h2.to_string ++ " " ++ 
      graphviz_scope_imports(scope, t)
  end;
}

@{-
 - Collect information to draw a list of declarations in graphviz.
 -
 - @param scopes The list of declarations to draw.
 - @return The graphviz string representing the list of declarations.
-}
function graphviz_scope_decls
String ::= scope::Decorated Scope<a> decls::[(String, Decorated Declaration<a>)]
{
  return case decls of 
    | [] -> ""
    | (h1, h2)::t -> 
      scope.to_string ++ " -> " ++ h2.to_string ++ " " ++ 
      (case h2.assoc_scope of 
        | nothing() -> "" 
        | just(s) -> "{ edge [arrowhead=onormal] " ++ h2.to_string ++ " -> " ++ s.to_string ++ "} " 
      end) ++ 
      graphviz_scope_decls(scope, t)
  end;
}