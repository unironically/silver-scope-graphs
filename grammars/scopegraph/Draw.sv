grammar scopegraph;

global graphviz_font_size :: String = "12";

{-====================-}

synthesized attribute string :: String occurs on 
  Graph_sg, Scope_sg, Scopes_sg, Decl_sg, Decls_sg, Ref_sg, Refs_sg;

{-====================-}

aspect production mk_graph
g::Graph_sg ::= root::Scope_sg
{
  g.string = "digraph {" ++ root.string ++ "}";
}

{-====================-}

aspect production mk_scope
s::Scope_sg ::= decls::Decls_sg refs::Refs_sg children::Scopes_sg
{
  s.string = 
    "{{node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++ "] \"" ++ s.name ++ "\"}" ++
    (case s.parent of nothing () -> "" | just (p) -> "\"" ++ s.name ++ "\"" ++ " -> " ++ "\"" ++ p.name ++ "\"" end) ++
    decls.string ++ refs.string ++ children.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref_sg -> str ++ " \"" ++ s.name ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
}

aspect production mk_scope_qid
s::Scope_sg ::= ref::Ref_sg
{
  s.string = 
    "{{node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++ "] \"" ++ s.name ++ "\"}" ++
    ref.string ++ 
    "{edge [arrowhead=onormal] " ++ foldl ((\str::String r::Decorated Ref_sg -> str ++ " \"" ++ s.name ++ "\" -> " ++ r.str), "", s.imps) ++ "}}";
}


aspect production mk_decl
d::Decl_sg ::= id::String
{
  d.string = 
    "{node [shape=box fontsize=" ++ graphviz_font_size ++ "]" ++ d.str ++ "}" ++
    "\"" ++ d.scope.name ++ "\" -> " ++ d.str;
}


aspect production mk_decl_assoc
d::Decl_sg ::= id::String s::Scope_sg
{
  d.string = 
    "{node [shape=box fontsize=" ++ graphviz_font_size ++ "]" ++ d.str ++ "}" ++ 
    "\"" ++ d.scope.name ++ "\" -> " ++ d.str ++
    "{edge [arrowhead=onormal] " ++ d.str ++ " -> \"" ++ s.name ++"\"}"++
    s.string;
}


aspect production mk_ref
r::Ref_sg ::= id::String
{
  r.string = 
  "{node [shape=box fontsize=" ++ graphviz_font_size ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.name ++ "\"";
}

aspect production mk_imp
r::Ref_sg ::= id::String
{
  r.string = 
  "{node [shape=box fontsize=" ++ graphviz_font_size ++ "]" ++ r.str ++ "}" ++
  r.str ++ " -> \"" ++ r.scope.name ++ "\"";
}

aspect production mk_ref_qid
r::Ref_sg ::= id::String s::Scope_sg
{
  r.string = 
    "{node [shape=box fontsize=" ++ graphviz_font_size ++ "]" ++ r.str ++ "}" ++ 
    r.str ++ " -> \"" ++ r.scope.name ++ "\"" ++
    s.string;
}


{-====================-}

aspect production scope_cons
ss::Scopes_sg ::= s::Scope_sg st::Scopes_sg
{
  ss.string = s.string ++ st.string;
}

aspect production scope_nil
ss::Scopes_sg ::=
{
  ss.string = "";
}

aspect production decl_cons
ds::Decls_sg ::= d::Decl_sg dt::Decls_sg
{
  ds.string = d.string ++ " " ++ dt.string;
}

aspect production decl_nil
ds::Decls_sg ::= 
{
  ds.string = "";
}

aspect production ref_cons
rs::Refs_sg ::= r::Ref_sg rt::Refs_sg
{
  rs.string = r.string ++ " " ++ rt.string;
}

aspect production ref_nil
rs::Refs_sg ::= 
{
  rs.string = "";
}