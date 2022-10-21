grammar lmlang_basic_scopegraph;

-- we assign this attribute to an undecorated scope so that it can be used in resolution

--inherited attribute look_for<r> :: r occurs on Scope<d r>, Ref<d r>; -- doesn't work
inherited attribute sg_look_for :: String occurs on Scope<d r>, Ref<d r>;

synthesized attribute sg_resolutions<d r>::[Decorated Decl<d r>] occurs on Scope<d r>, Ref<d r>;
{-
aspect production mk_scope
top::Scope<d r> ::=
  _ _ _ _
{
  top.resolutions = 
    let local_decls::[Decorated Decl<d r>] = 
      filter (
        (\decl::Decorated Decl<d r> -> decl.name == top.look_for),
        top.decls
      )
    in let parent_decls::[Decorated Decl<d r>] = 
      case top.parent of 
        | nothing() -> []
        | just(p) -> (decorate p with {look_for = top.look_for;}).resolutions
      end
    in
      if !null(local_decls)
        then local_decls
        else parent_decls
    end end;
}

aspect production mk_ref
top::Ref<d r> ::=
  _ _
{
  top.resolutions = (decorate top.in_scope with {look_for = top.look_for;}).resolutions;
}
-}