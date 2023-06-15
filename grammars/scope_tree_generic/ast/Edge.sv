grammar scope_tree_generic:ast;

nonterminal Edge;

synthesized attribute src::Scope occurs on Edge;
synthesized attribute label::Label occurs on Edge;
synthesized attribute dst::Scope occurs on Edge;

abstract production mk_edge
top::Edge ::= src::Scope label::Label dst::Scope
{
  top.src = src;
  top.label = label;
  top.dst = dst;
}