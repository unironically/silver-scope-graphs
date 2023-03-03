grammar scope_tree:rag_scopes_path;

imports scope_tree:ast;

synthesized attribute visible :: [ Decorated Dcl ] occurs on Ref;
synthesized attribute reachable :: [ [ Decorated Dcl ] ] occurs on Ref;

synthesized attribute scope_paths :: [ [(Maybe<String>, Decorated Scope)] ] 
  occurs on Ref, Scope;





function resolve
[(String, Integer)] ::= r::(String, Integer) s::ScopeGraph
{
  return sort (map (get_name_index_dcl, resolutions_here (r, s)));
}


function resolutions_here
[Decorated Dcl] ::= r::(String, Integer) s::ScopeGraph
{
  return case r of
    | (name, index) ->
       case filter (
              (\r::Decorated Ref -> r.name == name && r.index == index), 
              s.all_refs) of
         | [] -> []
         | [r] -> r.visible
         | _ -> error ("reference appeared multiple times in all_refs")
         end
    end;
}



aspect production root
gs::ScopeGraph ::= main::Scope
{
}

function fold_scopes
[(Maybe<String>, Decorated Scope)] ::=
   sofar::[(Maybe<String>, Decorated Scope)] d::Decorated Dcl
{ return case d.assoc_scope of
         | nothing() -> error ("all Dcls should be for imports")
         | just(s) -> (just(d.name),s) :: sofar
         end;
}


aspect production scope_tr
s::Scope ::= id::Integer dcls_tr::Dcls refs_tr::Refs imps_tr::Refs
{
  local resolved_imports :: [Decorated Dcl] = 
    foldl (\ sofar :: [Decorated Dcl]   r::Decorated Ref -> 
             r.visible ++ sofar, 
           [], s.imps) ;

  local imported_scopes :: [(Maybe<String>, Decorated Scope)] = 
    foldl (fold_scopes, [], resolved_imports);

  -- look on this scope, then imports on this scope
  -- then parent of this scope, then imports on parent ...
  s.scope_paths = 
    [(nothing(),s)] :: imported_scopes    --Env_L
    :: parent_scope_paths ;               --Env_P

  local parent_scope_paths :: [ [(Maybe<String>, Decorated Scope)] ] =
    case s.scope_parent of
      | nothing() -> []
      | just(p) -> p.scope_paths
    end;

}


function dcls_in_scope
[Decorated Dcl] ::= r::Decorated Ref dcls::[Decorated Dcl]
{
  return
    case dcls of
    | [] -> []
    | d::ds -> if d.name == r.name
               then d :: dcls_in_scope (r, ds)
               else dcls_in_scope (r, ds)
    end;
}

function local_resolutions
[Decorated Dcl] ::= r::Decorated Ref  seen::[Decorated Ref]
                    scopes::[(Maybe<String>,Decorated Scope)]
{
   return
    case scopes of
    | [] -> []
    | (nothing(),s) :: ss
        -> dcls_in_scope (r, s.dcls) ++ local_resolutions (r, seen, ss)
    | (just(nm),s) :: ss 
        -> if false --contains(nm, seen)
           then local_resolutions (r, seen, ss)
           else dcls_in_scope (r, s.dcls) ++ 
                  local_resolutions (r, seen, ss)
    end;
}

function resolutions
[ [ Decorated Dcl] ] ::= r::Decorated Ref  seen::[Decorated Ref] 
                         scope_paths::[ [(Maybe<String>,Decorated Scope)] ]
{
  return 
    case scope_paths of
    | [] -> []
    | scopes :: rest -> let dcls :: [Decorated Dcl] = 
                              local_resolutions (r, seen, scopes) 
                        in if null (dcls)
                           then resolutions (r, seen, rest)
                           else dcls :: resolutions (r, seen, rest)
                        end
    end;
}



aspect production dcl_tr
d::Dcl ::= n::String ind::Integer
{
}

aspect production dcl_scope_tr
d::Dcl ::= n::String ind::Integer s::Scope
{
}

aspect production dcl_nil
ds::Dcls ::=
{
}

aspect production dcl_cons
ds::Dcls ::= h::Dcl t::Dcls
{}


aspect production ref_tr
r::Ref ::= n::String ind::Integer
{
  r.scope_paths = r.parent.scope_paths;

  -- resolutions must be Dcls without an associated scope
  r.visible = case r.reachable of
                | [] -> []
                | h::t -> h
                end;
  
  r.reachable = resolutions (r, [r], r.parent.scope_paths);
}

aspect production imp_tr
i::Ref ::= n::String ind::Integer
{
  -- resolutions must be Dcls with an associated scope

  -- [ ]   - error, undeclared name used for an import
  -- [d]   -- OK - we have a Dcl
  -- [d1, d2] -- maybe an error, maybe OK
  i.visible = case i.reachable of
                | [] -> []
                | h::t -> h
                end;

  i.reachable = resolutions (i, [i], i.parent.scope_paths);

}

aspect production ref_nil
rs::Refs ::=
{
}

aspect production ref_cons
rs::Refs ::= h::Ref t::Refs
{
}



{-
function report
String ::= refs :: [Decorated Ref]
{ return
    concat (map ( \r::Decorated Ref -> r.name ++ ":" ++ toString (r.index) ++ 
                 case r.visible of
                 | [] -> " not declared \n"
                 | ds -> " is declared " ++
                              toString (length (ds)) ++ "\n"
                 end, refs) );
}  
-}
