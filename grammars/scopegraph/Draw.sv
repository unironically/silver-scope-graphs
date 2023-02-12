grammar scopegraph;

global graphviz_font_size :: String = "12";
global scope_format :: String = "node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++ "]";

function graphviz_draw_graph
String ::= root::Decorated Scope
{
  return "digraph {" ++ 
      "\n{node [shape=box fontsize=" ++ graphviz_font_size ++  "] edge [arrowhead=normal]\n" ++ 
      foldl((\acc::String cur::Decorated Scope -> acc ++ graphviz_draw_scope(cur)), "", root :: root.children) ++ 
      "}}";
}

function graphviz_draw_scope
String ::= s::Decorated Scope
{
  return
    "{" ++ scope_format ++ toString(s.id) ++ "}" ++ 
    graphviz_draw_decls (s.declsl) ++
    graphviz_draw_refs (s.refsl);
}

function graphviz_draw_decls
String ::= ds::[Decorated Decl]
{
  return foldl (
    (\acc::String d::Decorated Decl -> acc ++ " " ++ toString(d.parent.id) ++ "->" ++ d.name ++ "_D"),
    "",
    ds
  );
}

function graphviz_draw_refs
String ::= rs::[Decorated Ref]
{
  return foldl (
    (\acc::String r::Decorated Ref -> acc ++ " " ++ r.name ++ "_R ->" ++ toString(r.parent.id)),
    "",
    rs
  );
}