grammar scopegraph;


----------------
-- Resolution paths:

function graphviz_paths
String ::= paths::[Decorated Path<a>]
{
  return "digraph {" ++ graphviz_paths_helper(paths) ++ "}";
}

function graphviz_paths_helper
String ::= paths::[Decorated Path<a>]
{
  return case paths of 
    | [] -> ""
    | h::t -> h.start.to_string ++ "->" ++ h.final.to_string ++ " " ++ graphviz_paths_helper(t)
  end;
}

----------------
-- Scope graph:

function graphviz_scopes
String ::= graph::Decorated Graph<a>
{
  return "digraph {" ++ graphviz_scopes_helper(graph.scope_list) ++ "}";
}

function graphviz_scopes_helper
String ::= scopes::[Decorated Scope<a>]
{
  return case scopes of 
    | [] -> ""
    | h::t -> h.to_string ++ (case h.parent of | nothing() -> "" | just(p) -> " -> " ++ p.to_string end) ++ " " ++ graphviz_scopes_helper(t)
  end;
}