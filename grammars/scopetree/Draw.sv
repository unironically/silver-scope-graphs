grammar scopetree;

global graphviz_font_size::String = "12";

function graphviz_draw_graph
String ::= graph::Graph<d r>
{
  return "digraph {" ++ 

      "{ node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++ "] " ++
      graphviz_scope_labels(graph.root_scopes) ++ "}" ++ 

      "{ node [shape=box fontsize=" ++ graphviz_font_size ++  "] edge [arrowhead=normal] " ++ 
      foldl((\acc::String cur::Decorated Scope<d r> -> 
        acc ++ " " ++ graphviz_draw_declrefs(cur)), "", graph.root_scopes) ++ 
      "}" ++

      graphviz_parent_edges(graph.root_scopes) ++ 
    
    "}";
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

function graphviz_draw_declrefs
String ::= scope::Decorated Scope<d r>
{
  return 
    "\n" ++ foldl ( -- decls
      (\acc::String cur::Decorated Decl<d r> ->
        acc ++ " " ++ scope.str ++ "->" ++ cur.str ++
        (case cur.assoc_scope of nothing() -> "" | just(s) -> "{ edge [arrowhead=onormal]" ++ cur.str ++ "->" ++ s.str ++ "}" end)),
      "",
      scope.decls
    ) ++ "" ++

    "" ++ foldl( -- refs
      (\acc::String cur::Decorated Ref<d r> -> 
        acc ++ " " ++ cur.str ++ "->" ++ scope.str),
      "",
      scope.refs
    ) ++ "" ++

    "{edge [arrowhead=onormal]" ++ foldl( -- imports
      (\acc::String cur::Decorated Ref<d r> -> 
        acc ++ " " ++ scope.str ++ "->" ++ cur.str),
      "",
      scope.imps
    ) ++ "}" ++

    foldl ( -- continuing to child scopes
      (\acc::String cur::Decorated Scope<d r> -> 
        acc ++ " " ++ graphviz_draw_declrefs(cur)), 
      "", 
      scope.children
    );
}

function graphviz_parent_edges
String ::= scope_list::[Decorated Scope<d r>]
{
  return foldl(
    (\acc::String scope::Decorated Scope<d r> -> acc ++ " " ++ 
      case scope.parent of nothing() -> "" | just(p) -> scope.str ++ " -> " ++ p.str end ++ 
      graphviz_parent_edges(scope.children)),
    "",
    scope_list
  );
}