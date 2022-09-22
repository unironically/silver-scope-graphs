grammar scopetree;

--------------------
-- Scope nodes

@{-
 - Top-level resolution function
-}
function visser_decorating
[Decorated Decl<d r>] ::= 
  ref::Decorated Ref<d r> 
  cur_scope::Decorated Scope<d r>
{
  return 
    let collected_decls::[Decorated Decl<d r>] = 
      mergeCollectedDecls(ref, cur_scope)
    in
      filter (  
        (\d::Decorated Decl<d r> -> d.name == ref.name),
        collected_decls    
      )
  end;
}

@{-
 - Collect declarations from the current scope
-}
function check_scope
[Decorated Decl<d r>] ::= 
  ref::Decorated Ref<d r> 
  cur_scope::Decorated Scope<d r>
{
  return if !check_seen_scopes(cur_scope, ref.seen_scopes)
  then cur_scope.decls
  else [];
}

@{-
 - Collect declarations visible in the scopes found by imports
-}
function check_imports
[Decorated Decl<d r>] ::= 
  ref::Decorated Ref<d r> 
  cur_scope::Decorated Scope<d r>
{
  return [];
}

@{-
 - Collect declarations visible in the parent scopes
-}
function check_parent
[Decorated Decl<d r>] ::= 
  ref::Decorated Ref<d r> 
  cur_scope::Decorated Scope<d r>
{
  return if !check_seen_scopes(cur_scope, ref.seen_scopes)
  then 
    case cur_scope.parent of
      | nothing() -> []
      | just(p) -> 
        let decorated_ref::Decorated Ref<d r> = 
          decorate new(ref) with 
            {seen_imports = ref.seen_imports; seen_scopes = cur_scope::ref.seen_scopes;} 
        in
          mergeCollectedDecls(decorated_ref, p)
        end
    end
  else [];
}

@{-
 - Merge declarations found from parent, imports and current scope
-}
function mergeCollectedDecls
[Decorated Decl<d r>] ::=
  ref::Decorated Ref<d r> 
  cur_scope::Decorated Scope<d r>
{ 
  return 
     merge_declarations_with_shadowing (
      merge_declarations_with_shadowing (
        check_scope(ref, cur_scope), 
        check_imports(ref, cur_scope)), 
      check_parent(ref , cur_scope));
}