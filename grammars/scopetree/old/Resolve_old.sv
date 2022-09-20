grammar scopetree;
{-
function resolve_new
[Decl<d r>] ::= 
  ref::Decorated Ref<d r>
  cur_scope::Scope<d r>
{
  local attribute new_seen_scopes::[Scope<d r>] = ref.seen_scopes ++ [cur_scope];

  -- Check for any matching declarations in the current scope
  local attribute decls::[Decl<d r>] = filter(
    (\decl::Decl<d r> -> decl.name == ref.name), cur_scope.decls);

  -- Check any imports that exist, call resolve on them
  local attribute imps::[Decl<d r>] = foldl(
    (\acc::[Decl<d r>] cur::Decl<d r> -> acc ++ 
      case cur.assoc_scope of 
        | nothing() -> []
        | just(s) -> resolve_new((decorate new(ref) with {seen_imports = ref.seen_imports; seen_scopes = new_seen_scopes;}), s)
      end),
    [],
    foldl(

      -- Looping occuring here:
      (\acc::[Decl<d r>] cur::Ref<d r> -> 
        acc ++ 
        let n_decls::[Decl<d r>] = 
          
          -- (decorate cur with {seen_imports = ref.seen_imports ++ [cur]; seen_scopes = [];}).resolutions  -- Doesn't work, loops

          resolve_new( -- Works without looping
            (decorate cur with {seen_imports = ref.seen_imports ++ [cur]; seen_scopes = [];}), 
            cur.in_scope
          )
        
        in 
          n_decls
        end
      ),

      [],
      removeAllBy(
        (\left::Ref<d r> right::Ref<d r> -> left.str == right.str),
        ref.seen_imports,
        cur_scope.imps
      )
    )
  );

  -- Recursive call to parent scope
  local attribute par::[Decl<d r>] = case cur_scope.parent of
    | nothing() -> []
    | just(p) -> resolve_new((decorate new(ref) with {seen_imports = ref.seen_imports; seen_scopes = new_seen_scopes;}), p)
  end;

  
  return if check_seen_scopes(cur_scope, ref.seen_scopes) then 
    merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par))
  else 
    [];
  

  --return merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par));
}
-}
---------------------------
---------------------------
---------------------------


function lam_resolve_new
[Decl<d r>] ::= 
  ref::Ref<d r>
  cur_scope::Scope<d r>
  seen_imports::[Ref<d r>]
  seen_scopes::[Scope<d r>]
{
  local attribute new_seen_imports::[Ref<d r>] = seen_imports ++ [ref];
  local attribute new_seen_scopes::[Scope<d r>] = seen_scopes ++ [cur_scope];

  -- Check for any matching declarations in the current scope
  local attribute decls::[Decl<d r>] = filter(
    (\decl::Decl<d r> -> decl.name == ref.name), 
    unsafeTrace(cur_scope.decls, printT("Now resolving " ++ ref.str ++ ", in scope " ++ toString(cur_scope.id) ++ "\n", unsafeIO()))
  );

  -- Check any imports that exist, call resolve on them
  local attribute imps::[Decl<d r>] = foldl(
    (\acc::[Decl<d r>] cur::Decl<d r> -> acc ++ 
      case cur.assoc_scope of 
        | nothing() -> []
        | just(s) -> lam_resolve_new(ref, s, seen_imports, new_seen_scopes)
      end),
    [],
    foldl(

      -- Looping occuring here:
      (\acc::[Decl<d r>] cur::Ref<d r> -> 
        acc ++ 
        let n_decls::[Decl<d r>] = 
          
          
          -- Doesn't work, loops:
          -- (decorate cur with {seen_imports = ref.seen_imports ++ [cur]; seen_scopes = [];}).resolutions

          -- Works without looping but does not "save" intermediate resolution paths:
          {-
          resolve_new(
            (decorate cur with {seen_imports = new_seen_imports ++ [cur]; seen_scopes = [];}), 
            cur.in_scope
          )
          -}

          -- Work without looping, but does not "save" intermediate resolution paths
          -- lambda attribute: (?)
          cur.lam_resolutions(new_seen_imports, [])

          -- Doesn't work, loops:
          -- Using lambda attribute with seen_imports, seen_scopes from program AST
          -- cur.resolutions


        in 
          n_decls
        end
      ),

      [],
      removeAllBy(
        (\left::Ref<d r> right::Ref<d r> -> left.str == right.str),
        seen_imports,
        cur_scope.imps
      )
    )
  );

  -- Recursive call to parent scope
  local attribute par::[Decl<d r>] = case cur_scope.parent of
    | nothing() -> []
    | just(p) -> lam_resolve_new(ref, p, seen_imports, new_seen_scopes)
  end;

  
  return if check_seen_scopes(cur_scope, seen_scopes) then 
    merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par))
  else 
    [];
  

  --return merge_declarations_with_shadowing(decls, merge_declarations_with_shadowing(imps, par));
}

---------------------------
---------------------------
---------------------------

{-
def a = 0 def b = 1 def c = 2 let a = c b = a c = b in a + b + c
-}

function check_seen_scopes
Boolean ::= cur_scope::Scope<d r> seen_scopes::[Scope<d r>]
{
  return !containsBy((\left::Scope<d r> right::Scope<d r> -> left.id == right.id), cur_scope, seen_scopes);
}

function merge_declarations_with_shadowing
[Decl<d r>] ::= left::[Decl<d r>] right::[Decl<d r>]
{
  return unionBy(\mem_r::Decl<d r> mem_l::Decl<d r> -> 
    mem_r.name == mem_l.name, right , left);
}