grammar lmlang_basic_scopegraph;

inherited attribute sg_look_for :: Ref occurs on Scope, Ref;
inherited attribute sg_seen_scopes :: [Scope] occurs on Scope, Ref;
inherited attribute sg_seen_imports :: [Ref] occurs on Scope, Ref;

synthesized attribute sg_resolutions::[Decorated Decl] occurs on Ref;

synthesized attribute sg_resolutions_local::[Decorated Decl] occurs on Scope;
synthesized attribute sg_resolutions_parent::[Decorated Decl] occurs on Scope;
synthesized attribute sg_resolutions_import::[Decorated Decl] occurs on Scope;

synthesized attribute sg_envv::[Decorated Decl] occurs on Scope;
synthesized attribute sg_envl::[Decorated Decl] occurs on Scope;

aspect production mk_scope
top::Scope ::=
  _ _ _ _
{
  top.sg_resolutions_local = 
    filter (
      (\decl::Decorated Decl -> decl.name == top.sg_look_for.name),
      top.sg_decls);

  top.sg_resolutions_parent = 
    case top.sg_parent of 
        | nothing() -> []
        | just(p) -> 
          (decorate p with 
            { sg_look_for = top.sg_look_for; 
              sg_seen_scopes = top :: top.sg_seen_scopes; 
              sg_seen_imports = top.sg_seen_imports; 
            }
          ).sg_envv
      end;

  top.sg_resolutions_import =

    let valid_imps::[Ref] = 
      filter ((\r::Ref -> !is_seen_import(r, top.sg_seen_imports)), top.sg_imps)

    in let resolved_decls::[Decorated Decl] = 
      foldl (
        (\acc::[Decorated Decl] imp::Ref -> acc ++
          (decorate imp with {
            sg_look_for = imp;
            sg_seen_scopes = [];
            sg_seen_imports = top.sg_seen_imports; }
          ).sg_resolutions
        ), 
        [], 
        valid_imps)

    in let assoc_scopes::[Scope] = 
      foldl (
        (\acc::[Scope] d::Decorated Decl -> acc ++
          case d.sg_assoc_scope of
            | nothing() -> []
            | just(s) -> [s]
          end), 
        [], 
        resolved_decls)
    
    in
      foldl ((\acc::[Decorated Decl] s::Scope -> 
          (decorate s with {
            sg_look_for = top.sg_look_for;
            sg_seen_scopes = top :: top.sg_seen_scopes;
            sg_seen_imports = top.sg_seen_imports; }
          ).sg_envl), 
        [], 
        assoc_scopes)

    end end end;

  top.sg_envv = shadow (top.sg_envl, top.sg_resolutions_parent);
  top.sg_envl = shadow (top.sg_resolutions_local, top.sg_resolutions_import);
}

@{-
  - Aspect production for defining the resolutions attribute for reference nodes.
  - This is the 'entry point' for reference resolutions.
  -}
aspect production mk_ref
top::Ref ::=
  _ _
{
  top.sg_resolutions = 
    (decorate top.sg_in_scope with 
      { sg_look_for = top.sg_look_for;
        sg_seen_scopes = top.sg_seen_scopes;
        sg_seen_imports = top :: top.sg_seen_imports; 
      }
    ).sg_envv;
}

@{-
  - Implements the shadowing operator <|.
  - l1 <| l2, when elements in l1 shadow those in l2.
  - @param left the shadowing list.
  - @param right the shadowed list.
  - @return a list formed by merging left and right with shadowing.
  -}
function shadow
[Decorated Decl] ::= left::[Decorated Decl] right::[Decorated Decl]
{
  return unionBy (
      (\d1::Decorated Decl d2::Decorated Decl -> d1.name == d2.name), 
      right, 
      left
    );
}

@{-
  - Indicates whether a scope is in the list of seen scopes during a resolution.
  - @param scope the scope to check for.
  - @param seen_scopes the list of seen scopes.
  - @return a boolean indicating whether scope is in seen_scopes.
  -}
function is_seen_scope
Boolean ::= scope::Scope seen_scopes::[Scope]
{
  return containsBy (
      (\left::Scope right::Scope -> left.id == right.id), 
      scope, 
      seen_scopes
    );
}

@{-
  -}
function is_seen_import
Boolean ::= ref::Ref seen_imports::[Ref]
{
  return containsBy (
      (\left::Ref right::Ref -> left.str == right.str), 
      ref, 
      seen_imports
    );
}