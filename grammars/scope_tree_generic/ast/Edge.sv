grammar scope_tree_generic:ast;

nonterminal Edge;

synthesized attribute label::Label occurs on Edge;
synthesized attribute src::Scope occurs on Edge, Path;
synthesized attribute dst::Scope occurs on Edge, Path;

abstract production mk_edge
top::Edge ::= 
  --src::Scope 
  label::Label 
  dst::Scope
{
  --top.src = src;
  top.label = label;
  top.dst = dst;
}


nonterminal Edges;

abstract production edges_cons
top::Edges ::=  -- should i make this `Edges ::= Edges Edges` instead so that can use monoid attr?
  e::Edge 
  es::Edges
{}

abstract production edges_single
top::Edges ::=
  e::Edge
{ forwards to edges_cons (e, edges_none ()); }

abstract production edges_none
top::Edges ::= 
{}

abstract production edges_concat
top::Edges ::=
  e1::Edges
  e2::Edges
{
  forwards to 
    case e1 of 
      edges_none () -> e2
    | edges_cons (e, es) -> edges_cons (e, edges_concat (es, e2))
    end;
}


nonterminal Path;

abstract production path_cons
top::Path ::=
  e::Edge
  p::Path
{
  top.dst = p.dst;
  top.src = e.src;
}

abstract production path_single
top::Path ::=
  e::Edge
{
  top.dst = e.dst;
}
