grammar scope_tree:ast;

{-====================-}

inherited attribute scope_color :: Integer occurs on 
  Scope<d r>, Scopes<d r>, Ref<d r>, Refs<d r>, Dcl<d r>, Dcls<d r>;

synthesized attribute string :: String occurs on 
  Graph<d r>, Scope<d r>, Scopes<d r>, Dcl<d r>, Dcls<d r>, Ref<d r>, Refs<d r>;

{-====================-}

global graphviz_font_size :: String = "12";

global imp_edge_col :: String = "brown";
global dcl_edge_col :: String = "blue";
global ref_edge_col :: String = "green";
global par_edge_col :: String = "red";

{-====================-}

aspect production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  g.string = "digraph {" ++ root.string ++ "}\n";
  root.scope_color = 0;
}

aspect production mk_scope
s::Scope<d r> ::= 
  decls::Dcls<d r> 
  refs::Refs<d r> 
  children::Scopes<d r>
{
  local parent_edge :: String = 
    case s.parent of
      nothing () -> ""
    | just (p) -> "{" ++ par_edge_style ++ scope_str (s) ++ "->" ++ scope_str (p) ++ "}"
    end;

  s.string = 
    "{" ++ node_style_scope(s) ++
    parent_edge ++
    decls.string ++ refs.string ++ children.string ++ "{" ++ import_edge_style ++ import_edges (s) ++ "}}";

  children.scope_color = s.scope_color;
  decls.scope_color = s.scope_color;
  refs.scope_color = s.scope_color;
}

aspect production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{
  s.string = 
    "{" ++ node_style_scope (s) ++
    ref.string ++ 
    import_edges (s) ++ "}";

  ref.scope_color = s.scope_color;
}

aspect production mk_decl
d::Dcl<d r> ::= 
  _
{
  d.string = 
    node_style_declref (d) ++
    "{" ++ dcl_edge_style ++ scope_str (d.scope) ++ "->" ++ d.str_id ++ "}";
}

aspect production mk_decl_assoc
d::Dcl<d r> ::= 
  _
  module::Scope<d r> 
{
  d.string = module.string ++ 
    node_style_declref (d) ++ 
    "{" ++ dcl_edge_style ++ scope_str (d.scope) ++ "->" ++ d.str_id ++ "}" ++
    "{" ++ import_edge_style ++ d.str_id ++ "->" ++ scope_str (module) ++ "}";
  
  module.scope_color = d.scope_color + 1;
}

aspect production mk_ref
r::Ref<d r> ::= 
  _
{
  r.string = 
    node_style_declref (r) ++
    "{" ++ ref_edge_style ++ r.str_id ++ "->" ++ scope_str (r.scope) ++ "}";
}

aspect production mk_imp
r::Ref<d r> ::= 
  _
{
  r.string = 
    node_style_declref (r) ++
    "{" ++ ref_edge_style ++ r.str_id ++ "->" ++ scope_str (r.scope) ++ "}";
}

aspect production mk_ref_qid
r::Ref<d r> ::= 
  _
  qid_scope::Scope<d r> 
{
  r.string =
    node_style_declref (r) ++ 
    "{" ++ ref_edge_style ++ r.str_id ++ "->" ++ scope_str (r.scope) ++ "}" ++ qid_scope.string;
  
  qid_scope.scope_color = r.scope_color + 1;
}

{-====================-}

aspect production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{
  ss.string = s.string ++ st.string;
  s.scope_color = ss.scope_color + 1;
  st.scope_color = ss.scope_color + 1;
}

aspect production scope_nil
ss::Scopes<d r> ::=
{
  ss.string = "";
}

aspect production decl_cons
ds::Dcls<d r> ::= 
  d::Dcl<d r> 
  dt::Dcls<d r>
{ 
  propagate scope_color;
  ds.string = d.string ++ " " ++ dt.string;
}

aspect production decl_nil
ds::Dcls<d r> ::= 
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

global graphviz_fill_colors :: [String] = 
  ["#ffffff", "#dddddd", "#bbbbbb", "#999999"];

global import_edge_style :: String = "edge [arrowhead=onormal color=\"" ++ imp_edge_col ++ "\"]";
global dcl_edge_style :: String = "edge [arrowhead=normal color=\"" ++ dcl_edge_col ++ "\"]";
global ref_edge_style :: String = "edge [arrowhead=normal color=\"" ++ ref_edge_col ++ "\"]";
global par_edge_style :: String = "edge [arrowhead=normal color=\"" ++ par_edge_col ++ "\"]";

function node_style_scope
String ::= node::Decorated Scope<d r>
{ return "{" ++ node_style_both (node, true) ++  scope_str(node) ++ "}"; }

function node_style_declref
  attribute scope_color occurs on a,
  attribute str_id i occurs on a =>
String ::= node::Decorated a with i
{ return "{" ++ node_style_both (node, false) ++ "\"" ++ node.str_id ++ "\"}"; }

function node_style_both
  attribute scope_color occurs on a =>
String ::= node::Decorated a with i  is_scope::Boolean
{
  local shape :: String = if is_scope then "circle" else "box";
  return
    "node [style=filled shape=" ++ shape ++ 
          " fontsize=" ++ graphviz_font_size ++ 
          " fillcolor=" ++ node_color (node.scope_color) ++ "]";
}

function import_edges
String ::= s::Decorated Scope<d r>
{
  return
    "{" ++ import_edge_style ++ 
    implode (" ", 
      map ((\r::Decorated Ref<d r> -> scope_str (s) ++ "->" ++ r.str_id), s.imps)) ++
    "}";
}

function node_color
String ::= 
  i::Integer
{
  return 
    "\"" ++ 
    head (drop (i % length(graphviz_fill_colors), graphviz_fill_colors)) ++ 
    "\"";
}

function scope_str
String ::= s::Decorated Scope<d r>
{
  return "\"" ++ s.name ++ "\"";
}
