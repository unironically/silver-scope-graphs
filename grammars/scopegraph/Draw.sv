grammar scopegraph;

global graphviz_font_size :: String = "12";
global graphviz_fill_colors :: [String] = 
  ["#ffffff", "#ebebeb", "#d6d6d6", "#c0c0c0"];

inherited attribute scope_color :: Integer occurs on 
  Scope_sg, Scopes_sg, Ref_sg, Refs_sg, Decl_sg, Decls_sg;

{-====================-}

synthesized attribute string :: String occurs on 
  Graph_sg, Scope_sg, Scopes_sg, Decl_sg, Decls_sg, Ref_sg, Refs_sg;

{-====================-}

aspect production mk_graph
g::Graph_sg ::= root::Scope_sg
{
  g.string = "digraph {" ++ root.string ++ "}";
  root.scope_color = 0;
}

{-====================-}

aspect production mk_scope
s::Scope_sg ::= decls::Decls_sg refs::Refs_sg children::Scopes_sg
{
  s.string = 
    "{{node [shape=circle style=filled fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (s.scope_color) ++ "] \"" ++ s.name ++ "\"}" ++
    (case s.parent of nothing () -> "" | just (p) -> "\"" ++ s.name ++ "\"" ++ " -> " ++ "\"" ++ p.name ++ "\"" end) ++
    decls.string ++ refs.string ++ children.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref_sg -> str ++ " \"" ++ s.name ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
  children.scope_color = s.scope_color;
  decls.scope_color = s.scope_color;
  refs.scope_color = s.scope_color;
}

aspect production mk_scope_qid
s::Scope_sg ::= ref::Ref_sg
{
  s.string = 
    "{{node [shape=circle style=filled fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (s.scope_color) ++ "] \"" ++ s.name ++ "\"}" ++
    ref.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref_sg -> str ++ " \"" ++ s.name ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
  ref.scope_color = s.scope_color;
}

aspect production mk_decl
d::Decl_sg ::= id::String
{
  d.string = 
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (d.scope_color) ++ "]" ++ d.str ++ "}" ++
    "\"" ++ d.scope.name ++ "\" -> " ++ d.str;
}

aspect production mk_decl_assoc
d::Decl_sg ::= id::String s::Scope_sg
{
  d.string = s.string ++ 
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (d.scope_color) ++ "]" ++ d.str ++ "}" ++ 
    "\"" ++ d.scope.name ++ "\" -> " ++ d.str ++
    "{edge [arrowhead=onormal] " ++ d.str ++ " -> \"" ++ s.name ++"\"}";
  s.scope_color = d.scope_color + 1;
}

aspect production mk_ref
r::Ref_sg ::= id::String
{
  r.string = 
  "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.name ++ "\"";
}

aspect production mk_imp
r::Ref_sg ::= id::String
{
  r.string = 
  "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.name ++ "\"";
}

aspect production mk_ref_qid
r::Ref_sg ::= id::String s::Scope_sg
{
  r.string =
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++ 
    r.str ++ " -> \"" ++ r.scope.name ++ "\"" ++ s.stringj;
  s.scope_color = r.scope_color + 1;
}

{-====================-}

aspect production scope_cons
ss::Scopes_sg ::= s::Scope_sg st::Scopes_sg
{
  ss.string = s.string ++ st.string;
  s.scope_color = unsafeTrace(1 + ss.scope_color, printT(toString (1 + ss.scope_color) ++ "\n", unsafeIO()));
  st.scope_color = 1 + ss.scope_color;
}

aspect production scope_nil
ss::Scopes_sg ::=
{
  ss.string = "";
}

aspect production decl_cons
ds::Decls_sg ::= d::Decl_sg dt::Decls_sg
{ propagate scope_color;
  ds.string = d.string ++ " " ++ dt.string;
}

aspect production decl_nil
ds::Decls_sg ::= 
{
  ds.string = "";
}

aspect production ref_cons
rs::Refs_sg ::= r::Ref_sg rt::Refs_sg
{ propagate scope_color;
  rs.string = r.string ++ " " ++ rt.string;
}

aspect production ref_nil
rs::Refs_sg ::= 
{
  rs.string = "";
}

{-====================-}

function node_color
String ::= i::Integer
{
  return unsafeTrace (
    "\"" ++ head (drop (i % length(graphviz_fill_colors), graphviz_fill_colors)) ++ "\"",
    printT ("", unsafeIO())
  );
}