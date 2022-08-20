grammar scopetree;

function resolve_new
[Decl<d r>] ::= 
  ref::Ref<d r> 
  cur_scope::Scope<d r> 
  seen_scopes::[Scope<d r>] 
  seen_imports::[Ref<d r>]
{

  local attribute new_seen_scopes::[Scope<d r>] = seen_scopes ++ [cur_scope];
  local attribute new_seen_imports::[Ref<d r>] = seen_imports ++ [ref];

  -- Check for any matching declarations in the current scope
  local attribute decls::[Decl<d r>] = filter((\decl::Decl<d r> -> decl.name == ref.name), cur_scope.decls);
  
  -- Check any imports that exist, call resolve on them
  local attribute imps::[Decl<d r>] = foldl(
    (\acc::[Decl<d r>] cur::Decl<d r> -> acc ++ 
      case cur.assoc_scope of 
        | nothing() -> [] 
        | just(s) -> filter((\decl::Decl<d r> -> decl.name == ref.name), 
          resolve_new(ref, s, new_seen_scopes, new_seen_imports)) 
      end),
    [],
    foldl(
      (\acc::[Decl<d r>] cur::Ref<d r> -> 
        acc ++ (decorate cur with {
          seen_imports = new_seen_imports; 
          seen_scopes = new_seen_scopes;}).resolutions
      ),
      [],
      removeAllBy(
        (\left::Ref<d r> right::Ref<d r> -> left.str == right.str),
        new_seen_imports,
        cur_scope.imps
      )
    )
  );
  
  -- recursive call on parent
  local attribute par::[Decl<d r>] = case cur_scope.parent of
    | nothing() -> []
    | just(p) -> filter((\decl::Decl<d r> -> decl.name == ref.name), resolve_new(ref, p, new_seen_scopes, seen_imports))
  end;
  
  --return if check_seen_scopes(cur_scope, seen_scopes) then 
    --merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par))
    return if (length(decls) > 0) then
      decls
    else if (length(imps) > 0) then
      imps
    else
      par;
  --else 
  --  [];
}

function check_seen_scopes
Boolean ::= cur_scope::Scope<d r> seen_scopes::[Scope<d r>]
{
  return containsBy((\left::Scope<d r> right::Scope<d r> -> left.id == right.id), cur_scope, seen_scopes);
}

function merge_declarations_with_shadowing
[Decl<d r>] ::= left::[Decl<d r>] right::[Decl<d r>]
{
  return unionBy(\mem_r::Decl<d r> mem_l::Decl<d r> -> 
    mem_r.name == mem_l.name, right , left);
}