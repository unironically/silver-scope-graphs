grammar scopegraph;

global graphviz_font_size :: String = "12";

global scope_format :: String = "node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++ "]";
global node_format :: String = "node [shape=box fontsize=" ++ graphviz_font_size ++ "]";
global edge_format :: String = "edge [arrowhead=normal]";
global imp_edge_format :: String = "edge [arrowhead=onormal]";
global res_edge_format :: String = "edge [color=blue arrowhead=vee style=dashed]";

{-====================-}

function graphviz_draw_graph
String ::= g::Decorated Graph
{
  return "digraph {\n" ++ 
      "\t{" ++ scope_format ++ draw_scope_labels (g) ++ "}\n" ++
      "\t{" ++ node_format ++ draw_declrefs_labels_graph (g) ++ "}\n" ++
      "\t{" ++ node_format ++ edge_format ++ draw_scope (g) ++ "}\n}";
}

function draw_scope
String ::= g::Decorated Graph
{
  return 
    foldl(
      (\acc::String cur::Decorated Scope -> 
        acc ++ "{" ++ draw_scope_parent(cur) ++ draw_scope_children(cur) ++ "}"), 
      "", g.children);
}

function draw_scope_labels
String ::= g::Decorated Graph
{
  return implode (" ", map ((\s::Decorated Scope -> s.name), g.children));
}

function draw_scope_parent
String ::= s::Decorated Scope
{
  return case s.scope_parent of 
    | nothing () -> ""
    | just(p) -> s.name ++ "->" ++ p.name
  end;
}

function draw_scope_children
String ::= s::Decorated Scope
{
  return
    draw_decls (s.declsl) ++
    draw_refs (s.refsl) ++
    draw_imps (s.impsl, s);
}

function draw_decls
String ::= ds::[Decorated Decl]
{
  return foldl (
    (\acc::String d::Decorated Decl -> 
      acc ++ " " ++ d.parent.name ++ "->" ++ d.str ++ 
      case d.assoc_scope of 
        | nothing () -> ""
        | just (s) -> "{" ++ imp_edge_format ++ d.str ++ "->" ++ s.name ++ "}"
      end
    ),
    "",
    ds
  );
}

function draw_refs
String ::= rs::[Decorated Ref]
{
  return foldl (
    (\acc::String r::Decorated Ref -> 
      acc ++ " " ++ r.str ++ "->" ++ r.parent.name ++ " " ++ 
      "{" ++ res_edge_format ++ foldl ((\acc::String d::Decorated Decl -> acc ++ " " ++ r.str ++ "->" ++ d.str), "", r.res) ++ "}"), 
    "", 
    rs);
}

function draw_imps
String ::= rs::[Decorated Ref] s::Decorated Scope
{
  return 
    "{" ++ imp_edge_format ++ 
      foldl (
        (\acc::String r::Decorated Ref -> 
          acc ++ " " ++ s.name ++ "->" ++ r.str), "", rs) ++ 
    "}";
}

{-====================-}

function draw_declrefs_labels_graph
String ::= g::Decorated Graph
{
  return
    foldl (draw_declrefs_labels_scope, "", g.children);
}

function draw_declrefs_labels_scope
String ::= acc::String s::Decorated Scope
{
  return
    acc ++
    foldl (draw_decl_labels, "", s.declsl) ++
    foldl (draw_ref_labels, "", s.refsl);
}

function draw_decl_labels
String ::= acc::String d::Decorated Decl
{
  return 
    acc ++ d.str ++ "[label=<" ++ d.name ++ 
      "<SUB>" ++ d.substr ++ "</SUB><SUP>D</SUP>>] ";
}

function draw_ref_labels
String ::= acc::String r::Decorated Ref
{
  return 
    acc ++ r.str ++ "[label=<" ++ r.name ++ 
      "<SUB>" ++ r.substr ++ "</SUB><SUP>R</SUP>>] ";
}