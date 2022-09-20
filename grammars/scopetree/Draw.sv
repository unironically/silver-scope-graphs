grammar scopetree;

global graphviz_font_size::String = "12";

function graphviz_draw_graph
String ::= graph::Graph<d r>
{
  return "digraph {{ node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++  "] " ++
    graphviz_scope_labels(graph.root_scopes) ++
    "} node [shape=box fontsize=" ++ graphviz_font_size ++  "] edge [arrowhead=normal] " ++
    graphviz_parent_edges(graph) ++ "}";
}

function graphviz_scope_labels
String ::= scope_list::[Decorated Scope<d r>]
{
  return foldl(
    (\acc::String scope::Decorated Scope<d r> -> 
      acc ++ " " ++ scope.str ++ graphviz_scope_labels(scope.children)), 
    "", 
    scope_list);
}

function graphviz_parent_edges
String ::= graph::Graph<d r>
{
  return "";
}