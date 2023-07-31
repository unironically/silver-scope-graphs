grammar scope_tree_generic:ast;

{- Scope edges -}

synthesized attribute src::Scope occurs on Path;
synthesized attribute dst::Scope occurs on Path;
synthesized attribute word::[Label] occurs on Path;

{- Paths in query resolutions -}

nonterminal Path;

abstract production path_cons
top::Path ::=
  e::Scope
  l::Label
  p::Path
{
  top.dst = p.dst;
  top.src = e;
  top.word = l :: p.word;
}

abstract production path_single
top::Path ::=
  e::Scope
  l::Label
{
  top.dst = e;
  top.word = [l];
}
