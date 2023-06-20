grammar scope_tree_generic:ast;

nonterminal Edge;

synthesized attribute src::Scope occurs on Edge;
synthesized attribute label::Label occurs on Edge;
synthesized attribute dst::Scope occurs on Edge;

abstract production mk_edge
top::Edge ::= 
  src::Scope 
  label::Label 
  dst::Scope
{
  top.src = src;
  top.label = label;
  top.dst = dst;
}


nonterminal Edges;

abstract production edge_cons
top::Edges ::= 
  e::Edge 
  es::Edges
{}

abstract production edge_single
top::Edge ::= 
  e::Edge
{}


nonterminal Path;

abstract production path_cons
top::Path ::=
  e::Edge
  p::Path
{}

abstract production path_single
top::Path ::=
  e::Edge
{}