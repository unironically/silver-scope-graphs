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