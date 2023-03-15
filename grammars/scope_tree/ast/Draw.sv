grammar scope_tree:ast;

global graphviz_font_size :: String = "12";
global graphviz_fill_colors :: [String] = 
  ["#ffffff", "#ebebeb", "#d6d6d6", "#c0c0c0"];

{-====================-}

inherited attribute scope_color :: Integer occurs on 
  Scope<a>, Scopes<a>, Ref<a>, Refs<a>, Decl<a>, Decls<a>;

synthesized attribute string :: String occurs on 
  Graph<a>, Scope<a>, Scopes<a>, Decl<a>, Decls<a>, Ref<a>, Refs<a>;

{-====================-}

aspect production mk_graph
g::Graph<a> ::= 
  root::Scope<a>
{
  g.string = "digraph {" ++ root.string ++ "}";
  root.scope_color = 0;
}

aspect production mk_scope
s::Scope<a> ::= 
  decls::Decls<a> 
  refs::Refs<a> 
  children::Scopes<a>
{
  s.string = 
    "{{node [shape=circle style=filled fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (s.scope_color) ++ "] \"" ++ s.id ++ "\"}" ++
    (case s.parent of nothing () -> "" | just (p) -> "\"" ++ s.id ++ "\"" ++ " -> " ++ "\"" ++ p.id ++ "\"" end) ++
    decls.string ++ refs.string ++ children.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref<a> -> str ++ " \"" ++ s.id ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
  children.scope_color = s.scope_color;
  decls.scope_color = s.scope_color;
  refs.scope_color = s.scope_color;
}

aspect production mk_scope_qid
s::Scope<a> ::= 
  ref::Ref<a>
{
  s.string = 
    "{{node [shape=circle style=filled fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (s.scope_color) ++ "] \"" ++ s.id ++ "\"}" ++
    ref.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref<a> -> str ++ " \"" ++ s.id ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
  ref.scope_color = s.scope_color;
}

aspect production mk_decl
d::Decl<a> ::= 
  id::String 
  _
{
  d.string = 
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (d.scope_color) ++ "]" ++ d.str ++ "}" ++
    "\"" ++ d.scope.id ++ "\" -> " ++ d.str;
}

aspect production mk_decl_assoc
d::Decl<a> ::= 
  id::String 
  s::Scope<a> 
  _
{
  d.string = s.string ++ 
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (d.scope_color) ++ "]" ++ d.str ++ "}" ++ 
    "\"" ++ d.scope.id ++ "\" -> " ++ d.str ++
    "{edge [arrowhead=onormal] " ++ d.str ++ " -> \"" ++ s.id ++"\"}";
  s.scope_color = d.scope_color + 1;
}

aspect production mk_ref
r::Ref<a> ::= 
  id::String 
  _
{
  r.string = 
  "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.id ++ "\"";
}

aspect production mk_imp
r::Ref<a> ::= 
  id::String 
  _
{
  r.string = 
  "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.id ++ "\"";
}

aspect production mk_ref_qid
r::Ref<a> ::= 
  id::String 
  s::Scope<a> 
  _
{
  r.string =
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++ 
    r.str ++ " -> \"" ++ r.scope.id ++ "\"" ++ s.string;
  s.scope_color = r.scope_color + 1;
}

{-====================-}

aspect production scope_cons
ss::Scopes<a> ::= 
  s::Scope<a> 
  st::Scopes<a>
{
  ss.string = s.string ++ st.string;
  s.scope_color = unsafeTrace(1 + ss.scope_color, printT(toString (1 + ss.scope_color) ++ "\n", unsafeIO()));
  st.scope_color = 1 + ss.scope_color;
}

aspect production scope_nil
ss::Scopes<a> ::=
{
  ss.string = "";
}

aspect production decl_cons
ds::Decls<a> ::= 
  d::Decl<a> 
  dt::Decls<a>
{ 
  propagate scope_color;
  ds.string = d.string ++ " " ++ dt.string;
}

aspect production decl_nil
ds::Decls<a> ::= 
{
  ds.string = "";
}

aspect production ref_cons
rs::Refs<a> ::= 
  r::Ref<a> 
  rt::Refs<a>
{ 
  propagate scope_color;
  rs.string = r.string ++ " " ++ rt.string;
}

aspect production ref_nil
rs::Refs<a> ::= 
{
  rs.string = "";
}

{-====================-}

function node_color
String ::= 
  i::Integer
{
  return unsafeTrace (
    "\"" ++ head (drop (i % length(graphviz_fill_colors), graphviz_fill_colors)) ++ "\"",
    printT ("", unsafeIO())
  );
}