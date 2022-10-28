grammar lmlang_basic_scopegraph;

inherited attribute sg_look_for :: Ref occurs on Scope, Ref;
inherited attribute sg_seen_scopes :: [Scope] occurs on Scope, Ref;
inherited attribute sg_seen_imports :: [Ref] occurs on Scope, Ref;

synthesized attribute sg_resolutions::[Decorated Decl] occurs on Scope, Ref;

aspect production mk_scope
top::Scope ::=
  _ _ _ _
{
  -- Declarations in this scope
  local local_decls::[Decorated Decl] = 
    filter (
      (\decl::Decorated Decl -> decl.name == top.sg_look_for.name),
      top.sg_decls);

  -- Declarations from parent scope
  local parent_decls::[Decorated Decl] = 
    case top.sg_parent of 
        | nothing() -> []
        | just(p) -> 
          (decorate p with 
            {sg_look_for = top.sg_look_for; 
             sg_seen_scopes = top::top.sg_seen_scopes; 
             sg_seen_imports = top.sg_seen_imports;}
          ).sg_resolutions
      end;

  -- Imported declarations
  local import_decls::[Decorated Decl] =
    
    -- Get the import nodes from this scope whose name matches the name we're trying to resolve
    let filtered_refs::[Ref] = 
      filter((\r::Ref -> 
        !is_seen_imp(r, top.sg_seen_imports)), top.sg_imps) 
    in

    -- Try to find the declarations for those imports
    let modules::[Decorated Decl] = 
      foldl (
        (\acc::[Decorated Decl] cur::Ref -> acc ++ 
          ((decorate cur with 
            {sg_look_for = cur; 
             sg_seen_scopes = []; 
             sg_seen_imports = top.sg_seen_imports;}
          ).sg_resolutions)), 
        [], 
        filtered_refs
      ) 
    in
    
    -- Resolve the original reference within the associated scopes of the declarations found
    let module_decls::[Decorated Decl] = 
      foldl (
        (\acc::[Decorated Decl] cur::Decorated Decl -> acc ++ 
          (case cur.sg_assoc_scope of 
            | nothing() -> [] 
            | just(p) -> 
              (decorate p with 
                {sg_look_for = top.sg_look_for; 
                 sg_seen_scopes = top::top.sg_seen_scopes; 
                 sg_seen_imports = top.sg_look_for::top.sg_seen_imports;}
              ).sg_resolutions
          end)),
        [], 
        modules
      ) 
    in
    
    module_decls
    end end end;

  -- Final resolutions
  top.sg_resolutions = 
    if !is_seen_scope(top, top.sg_seen_scopes)
      then shadow_decls(local_decls, shadow_decls(import_decls, parent_decls))
      else [];
  
}

-- Initial call to resolve handled here
aspect production mk_ref
top::Ref ::=
  _ _
{
  top.sg_resolutions = 
    (decorate top.sg_in_scope with 
      {sg_look_for = top.sg_look_for;
       sg_seen_scopes = top.sg_seen_scopes;
       sg_seen_imports = top::top.sg_seen_imports;}
    ).sg_resolutions;
}

function shadow_decls
[Decorated Decl] ::= left::[Decorated Decl] right::[Decorated Decl]
{
  return unionBy((\d1::Decorated Decl d2::Decorated Decl -> d1.name == d2.name), right, left);
}

function is_seen_scope
Boolean ::= scope::Scope seen_scopes::[Scope]
{
  return containsBy((\left::Scope right::Scope -> left.id == right.id), scope, seen_scopes);
}

function is_seen_imp
Boolean ::= ref::Ref seen_imps::[Ref]
{
  return containsBy((\r::Ref seen::Ref -> r.str == seen.str), ref, seen_imps);
}