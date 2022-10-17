grammar scopegraph;

-- we assign this attribute to an undecorated scope so that it can be used in resolution
inherited attribute look_for<r> :: r occurs on Scope<d r>, Ref<d r>;

synthesized attribute resolutions<d r>::[Decorated Decl<d r>] occurs on Scope<d r>, Ref<d r>;

aspect production mk_scope
top::Scope<d r> ::=
  _ _ _ _
{
  
}

aspect production mk_ref
top::Ref<d r> ::=
  _ _
{
  top.resolutions = (decorate top.in_scope with {look_for = top.look_for;}).resolutions;
}