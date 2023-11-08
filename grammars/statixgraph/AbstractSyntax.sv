grammar statixgraph;

{--}

synthesized attribute string :: String occurs on 
  Graph, ScopeAsserts, ScopeAssert, DatumAssert, EdgeAsserts, EdgeAssert;

global graphviz_font_size :: String = "12";

{--}

nonterminal Graph;

abstract production graph
top::Graph ::=
  scopes::ScopeAsserts
{
  top.string = "digraph {" ++ scopes.string ++ "}\n";
}

nonterminal ScopeAsserts;

abstract production consScopeAsserts
top::ScopeAsserts ::=
  h::ScopeAssert t::ScopeAsserts
{
  top.string = h.string ++ " " ++ t.string;
}

abstract production oneScopeAsserts
top::ScopeAsserts ::= 
  h::ScopeAssert
{
  top.string = h.string;
}

{--}

nonterminal ScopeAssert;

abstract production scopeAssert
top::ScopeAssert ::= 
  id::Integer datum::DatumAssert edges::EdgeAsserts
{
  edges.from = id;
  top.string = "{ " ++ toString(id) ++ 
    "[label=\"" ++ toString(id) ++ " |-> " ++ datum.string ++ "\", shape=circle]" ++ " " ++ 
    edges.string ++ "}";
}

{--}

nonterminal DatumAssert;

abstract production datumAssertNothing
top::DatumAssert ::=
{
  top.string = "()";
}

abstract production datumAssertNameTy
top::DatumAssert ::=
  name::String ty::String
{
  top.string = name ++ " : " ++ ty;
}

{--}

nonterminal EdgeAsserts;

inherited attribute from::Integer occurs on EdgeAsserts, EdgeAssert;

abstract production consEdgeAsserts
top::EdgeAsserts ::=
  h::EdgeAssert t::EdgeAsserts
{
  propagate from;
  top.string = h.string ++ " " ++ t.string;
}

abstract production nilEdgeAsserts
top::EdgeAsserts ::=
{
  top.string = "";
}

{--}

nonterminal EdgeAssert;

abstract production edgeAssert
top::EdgeAssert ::=
  edge::String tgt::Integer
{
  top.string = "{ edge [label=" ++ edge ++ "]" ++ toString(top.from) ++ " -> " ++ toString(tgt) ++ "}";
} 