grammar sc;

nonterminal Scope;

synthesized attribute dcls :: [ Decorated Dcl ] occurs on Scope, Dcls;
synthesized attribute refs :: [ Decorated Ref ] occurs on Scope, Refs, Ref;
synthesized attribute imps :: [ Decorated Ref ] occurs on Scope, Refs, Ref;

inherited attribute parent :: Decorated Scope occurs on Ref, Refs, Dcl, Dcls, Scope;

synthesized attribute reachable :: [ Decorated Dcl ] occurs on Ref;
synthesized attribute visible :: [ [ Decorated Dcl ] ] occurs on Ref;

synthesized attribute scope_paths :: [ [Decorated Scope] ] occurs on Ref, Scope;

synthesized attribute name :: String occurs on Dcl, Ref;


production root_scope
gs::Scope ::= main::Scope
{
  gs.scope_paths = [];
  main.parent = gs; 
}

function fold_dcls
[ Decorated Dcl] ::= sofar :: [Decorated Dcl] r::Decorated Ref
{ return r.reachable ++ sofar; }

function fold_scopes
[ Decorated Scope] ::= sofar :: [Decorated Scope] d::Decorated Dcl
{ return case d.assoc_scope of
         | nothing() -> sofar
         | just(s) -> s :: sofar
         end;
}

production scope_tr
s::Scope ::= dcls_tr::Dcls refs_tr::Refs imps_tr::Refs
{
  dcls_tr.parent = s; refs_tr.parent = s; imps_tr.parent = s;

  s.dcls = dcls_tr.dcls;
  s.refs = refs_tr.refs;
  s.imps = imps_tr.imps;

  local resolved_imports :: [Decorated Dcl] = 
    foldl (fold_dcls, [], s.imps) ;

  local imported_scopes :: [Decorated Scope] =
    foldl (fold_scopes, [], resolved_imports);

  -- look on this scope, then imports on this scope
  -- then parent of this scope, then imports on parent ...
  s.scope_paths = [s] :: imported_scopes :: s.parent.scope_paths ;
}

function dcls_in_scope
[Decorated Dcl] ::= name::String dcls::[Decorated Dcl]
{
  return
    case dcls of
    | [] -> []
    | d::ds -> if d.name == name
               then d :: dcls_in_scope (name, ds)
               else dcls_in_scope (name, ds)
    end;
}

function local_resolutions
[Decorated Dcl] ::= name::String  scopes::[Decorated Scope]
{
  return 
    case scopes of
    | [] -> []
    | s::ss -> dcls_in_scope (name, s.dcls) ++ local_resolutions (name, ss)
    end;
}

function resolutions
[ [ Decorated Dcl] ] ::= name::String  scope_paths::[ [Decorated Scope] ]
{
  return 
    case scope_paths of
    | [] -> []
    | scopes :: rest -> let dcls :: [Decorated Dcl] = local_resolutions (name, scopes) 
                        in if null (dcls)
                           then resolutions (name, rest)
                           else dcls :: resolutions (name, rest)
                        end
    end;
}

--------------------------------------------------
nonterminal Dcl;
nonterminal Dcls;

{- Declarations have 
   - an associated scope, optionally
   - a reference to the AST node of the declaration
 -}
synthesized attribute assoc_scope :: Maybe <Decorated Scope> occurs on Dcl;

production dcl_tr
d::Dcl ::= n::String
{ d.name = n;
  d.assoc_scope = nothing();
}

production dcl_scope_tr
d::Dcl ::= n::String s::Scope
{ d.name = n;
  d.assoc_scope = just(s);
  s.parent = d.parent;
}


production dcl_nil
ds::Dcls ::=
{ ds.dcls = []; 
}

production dcl_cons
ds::Dcls ::= h::Dcl t::Dcls
{ ds.dcls = h :: t.dcls;
  h.parent = ds.parent;  t.parent = ds.parent;
}

--------------------------------------------------
nonterminal Ref;
nonterminal Refs;

production ref_tr
r::Ref ::= n::String
{ r.name = n;
  r.refs = [r];
  r.imps = [];

  r.scope_paths = r.parent.scope_paths;

  -- resolutions must be Dcls without an associated scope
  r.reachable = case r.visible of
                | [] -> []
                | h::t -> h
                end;
  
  r.visible = resolutions (n, r.parent.scope_paths);

  r.all_refs <- [r];
}


production imp_tr
i::Ref ::= n::String
{ i.name = n;
  i.refs = [];
  i.imps = [i];

  -- resolutions must be Dcls with an associated scope

  -- [ ]   - error, undeclared name used for an import
  -- [d]   -- OK - we have a Dcl
  -- [d1, d2] -- maybe an error, maybe OK
  i.reachable = case i.visible of
                | [] -> []
                | h::t -> h
                end;

  i.visible = resolutions (n, i.parent.scope_paths);

  i.all_refs <- [i];
}


production ref_nil
rs::Refs ::=
{
  rs.refs = [];
  rs.imps = [];
}

production ref_cons
rs::Refs ::= h::Ref t::Refs
{
  rs.refs = h.refs ++ t.refs;
  rs.imps = h.imps ++ t.imps;

  h.parent = rs.parent;
  t.parent = rs.parent;
}


-- collecting things to the top for reporting
monoid attribute all_refs :: [Decorated Ref] occurs on Ref, Refs, Dcl, Dcls, Scope;

propagate all_refs on Ref, Refs, Dcl, Dcls, Scope;

function report
String ::= refs :: [Decorated Ref]
{ return
    concat (map ( \r::Decorated Ref -> case r.reachable of
                     | [] -> r.name ++ " not declared \n"
                     | ds -> r.name ++ " is declared " ++
                              toString (length (ds)) ++ "\n"
                     end, refs) );
}  
