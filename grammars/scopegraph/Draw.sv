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
    "{" ++ scope_format ++ toString (s.id) ++ "}" ++ 
    graphviz_draw_parent (s) ++
    graphviz_draw_decls (s.declsl) ++
    graphviz_draw_refs (s.refsl) ++
    graphviz_draw_imps (s.impsl);
}

function graphviz_draw_parent
String ::= s::Decorated Scope
{
  return case s.scope_parent of 
    | nothing () -> ""
    | just(p) -> toString (s.id) ++ "->" ++ toString (p.id)
  end;
}

function graphviz_draw_decls
String ::= ds::[Decorated Decl]
{
  return foldl (
    (\acc::String d::Decorated Decl -> 
      acc ++ " " ++ toString(d.parent.id) ++ "->" ++ d.str ++ 
      case d.assoc_scope of 
        | nothing () -> ""
        | just (s) -> "{edge [arrowhead=onormal]" ++ d.str ++ "->" ++ toString (s.id) ++ "}"
      end
    ),
    "",
    ds
  );
}

function graphviz_draw_refs
String ::= rs::[Decorated Ref]
{
  return foldl (
    (\acc::String r::Decorated Ref -> 
      acc ++ " " ++ r.str ++ "->" ++ toString(r.parent.id)),
    "",
    rs
  );
}

function graphviz_draw_imps
String ::= rs::[Decorated Ref]
{
  return 
    "{edge [arrowhead=onormal]" ++ 
      foldl (
        (\acc::String r::Decorated Ref -> 
          acc ++ " " ++ toString(r.parent.id) ++ "->" ++ r.str),
        "",
        rs) ++
    "}";
}