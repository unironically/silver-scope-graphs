grammar scopegraph;

global graphviz_font_size::String = "12";

function graphviz_draw_graph
String ::= graph::Graph<d r>
{
  return "digraph {" ++ 

      "\n{node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++ "] " ++
      graphviz_scope_labels(graph.root_scopes) ++ "}" ++ 

      "\n{node [shape=box fontsize=" ++ graphviz_font_size ++  "] edge [arrowhead=normal]\n" ++ 
      foldl((\acc::String cur::Decorated Scope<d r> -> 
        acc ++ graphviz_draw_declrefs(cur)), "", graph.root_scopes) ++ 
      "}\n" ++

      graphviz_parent_edges(graph.root_scopes) ++ 
    
    "\n}";
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
    "/* Scope " ++ scope.str ++ " */" ++ foldl ( -- decls
      (\acc::String cur::Decorated Decl<d r> ->
        acc ++ " " ++ scope.str ++ "->" ++ cur.str ++
        case cur.assoc_scope of nothing() -> "" | just(s) -> 
          "{edge [arrowhead=onormal]" ++ cur.str ++ "->" ++ s.str ++ "}" end),
      "",
      scope.decls
    ) ++ "" ++

    "" ++ foldl( -- refs
      (\acc::String cur::Decorated Ref<d r> -> 
        acc ++ " " ++ cur.str ++ "->" ++ scope.str ++ "{ edge [color=blue]" ++
        foldl((\acc::String res::Decorated Decl<d r> -> 
          acc ++ cur.str ++ "->" ++ res.str ++ " "), "", cur.resolutions) ++ "}"),
      "",
      scope.refs
    ) ++ " " ++

    "{edge [arrowhead=onormal]" ++ foldl( -- imports
      (\acc::String cur::Decorated Ref<d r> -> 
        acc ++ " " ++ scope.str ++ "->" ++ cur.str ++ "{ edge [color=blue arrowhead=tee]" ++
        
        if cur.in_scope.id == scope.id -- hacky way to make sure two resolution arrows don't come from certain imports
        then foldl((\acc::String res::Decorated Decl<d r> -> 
          acc ++ cur.str ++ "->" ++ res.str ++ " "), "", cur.resolutions) 
        else ""

        ++ "}"),
      "",
      scope.imps
    ) ++ "}\n" ++

    foldl ( -- continuing to child scopes
      (\acc::String cur::Decorated Scope<d r> -> 
        acc ++ graphviz_draw_declrefs(cur)), 
      "", 
      scope.children
    );
}

function graphviz_parent_edges
String ::= scope_list::[Decorated Scope<d r>]
{
  return foldl(
    (\acc::String scope::Decorated Scope<d r> -> acc ++ 
      case scope.parent of nothing() -> "" | just(p) -> scope.str ++ "->" ++ p.str ++ " " end ++
      graphviz_parent_edges(scope.children)),
    "",
    scope_list
  );
}