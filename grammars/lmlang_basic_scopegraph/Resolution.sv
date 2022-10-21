grammar lmlang_basic_scopegraph;

-- we assign this attribute to an undecorated scope so that it can be used in resolution

--inherited attribute look_for<r> :: r occurs on Scope<d r>, Ref<d r>; -- doesn't work
inherited attribute sg_look_for :: String occurs on Scope<d r>, Ref<d r>;

synthesized attribute sg_resolutions<d r>::[Decorated Decl<d r>] occurs on Scope<d r>, Ref<d r>;

aspect production mk_scope
top::Scope<d r> ::=
  _ _ _ _
{
  top.sg_resolutions = 
    let local_decls::[Decorated Decl<d r>] = 
      filter (
        (\decl::Decorated Decl<d r> -> decl.name == top.sg_look_for),
        top.sg_decls
      )
    in let parent_decls::[Decorated Decl<d r>] = 
      case top.sg_parent of 
        | nothing() -> []
        | just(p) -> (decorate p with {sg_look_for = top.sg_look_for;}).sg_resolutions
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
  top.sg_resolutions = 
    (decorate top.sg_in_scope with {sg_look_for = top.sg_look_for;}).sg_resolutions;
}
