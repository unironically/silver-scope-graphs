grammar scope_tree:ast;

global graphviz_font_size :: String = "12";
global graphviz_fill_colors :: [String] = 
  ["#ffffff", "#ebebeb", "#d6d6d6", "#c0c0c0"];

{-====================-}

inherited attribute scope_color :: Integer occurs on 
  Scope<d r>, Scopes<d r>, Ref<d r>, Refs<d r>, Decl<d r>, Decls<d r>;

synthesized attribute string :: String occurs on 
  Graph<d r>, Scope<d r>, Scopes<d r>, Decl<d r>, Decls<d r>, Ref<d r>, Refs<d r>;

{-====================-}

aspect production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  g.string = "digraph {" ++ root.string ++ "}";
  root.scope_color = 0;
}

aspect production mk_scope
s::Scope<d r> ::= 
  decls::Decls<d r> 
  refs::Refs<d r> 
  children::Scopes<d r>
{
  s.string = 
    "{{node [shape=circle style=filled fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (s.scope_color) ++ "] \"" ++ s.id ++ "\"}" ++
    (case s.parent of nothing () -> "" | just (p) -> "\"" ++ s.id ++ "\"" ++ " -> " ++ "\"" ++ p.id ++ "\"" end) ++
    decls.string ++ refs.string ++ children.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref<d r> -> str ++ " \"" ++ s.id ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
  children.scope_color = s.scope_color;
  decls.scope_color = s.scope_color;
  refs.scope_color = s.scope_color;
}

aspect production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{
  s.string = 
    "{{node [shape=circle style=filled fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (s.scope_color) ++ "] \"" ++ s.id ++ "\"}" ++
    ref.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref<d r> -> str ++ " \"" ++ s.id ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
  ref.scope_color = s.scope_color;
}

aspect production mk_decl
d::Decl<d r> ::= 
  _
{
  d.string = 
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (d.scope_color) ++ "]" ++ d.str ++ "}" ++
    "\"" ++ d.scope.id ++ "\" -> " ++ d.str;
}

aspect production mk_decl_assoc
d::Decl<d r> ::= 
  _
  module::Scope<d r> 
{
  d.string = module.string ++ 
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (d.scope_color) ++ "]" ++ d.str ++ "}" ++ 
    "\"" ++ d.scope.id ++ "\" -> " ++ d.str ++
    "{edge [arrowhead=onormal] " ++ d.str ++ " -> \"" ++ module.id ++"\"}";
  module.scope_color = d.scope_color + 1;
}

aspect production mk_ref
r::Ref<d r> ::= 
  _
{
  r.string = 
  "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.id ++ "\"";
}

aspect production mk_imp
r::Ref<d r> ::= 
  _
{
  r.string = 
  "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.id ++ "\"";
}

aspect production mk_ref_qid
r::Ref<d r> ::= 
  _
  qid_scope::Scope<d r> 
{
  r.string =
    "{node [style=filled shape=box fontsize=" ++ graphviz_font_size ++ " fillcolor=" ++ node_color (r.scope_color) ++ "]" ++ r.str ++ "}" ++ 
    r.str ++ " -> \"" ++ r.scope.id ++ "\"" ++ qid_scope.string;
  qid_scope.scope_color = r.scope_color + 1;
}

{-====================-}

aspect production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{
  ss.string = s.string ++ st.string;
  s.scope_color = unsafeTrace(1 + ss.scope_color, printT(toString (1 + ss.scope_color) ++ "\n", unsafeIO()));
  st.scope_color = 1 + ss.scope_color;
}

aspect production scope_nil
ss::Scopes<d r> ::=
{
  ss.string = "";
}

aspect production decl_cons
ds::Decls<d r> ::= 
  d::Decl<d r> 
  dt::Decls<d r>
{ 
  propagate scope_color;
  ds.string = d.string ++ " " ++ dt.string;
}

aspect production decl_nil
ds::Decls<d r> ::= 
{
  ds.string = "";
}

aspect production ref_cons
rs::Refs<d r> ::= 
  r::Ref<d r> 
  rt::Refs<d r>
{ 
  propagate scope_color;
  rs.string = r.string ++ " " ++ rt.string;
}

aspect production ref_nil
rs::Refs<d r> ::= 
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