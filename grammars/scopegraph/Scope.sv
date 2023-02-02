grammar scopegraph;

nonterminal Scope;
nonterminal Decl;
nonterminal Ref;
nonterminal Imp;

{-====================-}

inherited attribute parent_scope::Decorated Scope occurs on Scope, Decl, Decls, Ref, Refs, Imp, Imps;
--synthesized attribute reachable_scopes::[[Decorated Scope]] occurs on Scope;
synthesized attribute resolutions::[Decorated Decl] occurs on Ref, Refs, Imp;
synthesized attribute assoc_scope::Maybe<Decorated Scope> occurs on Decl;
synthesized attribute name::String occurs on Decl, Ref, Imp;
inherited attribute other_imps::[Decorated Imp] occurs on Imp;

synthesized attribute local_decls::[Decorated Decl] occurs on Scope;
synthesized attribute imported_scopes::[Decorated Scope] occurs on Scope, Imps;
synthesized attribute parent_scopes::[Decorated Scope] occurs on Scope;

{-====================-}



abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs imps::Imps
{
  decls.parent_scope = s; refs.parent_scope = s; imps.parent_scope = s;

  --s.reachable_scopes = 
  --  imps.imported_scopes :: [s.parent_scope] :: s.parent_scope.reachable_scopes;
    
  imps.all_imps = imps.imps;

  s.local_decls = decls.decls_list;
  s.imported_scopes = imps.imported_scopes;
  s.parent_scopes = s.parent_scope.parent_scopes;
}

abstract production mk_scope_orphan {- TODO -}
s::Scope ::=
{ 
  s.parent_scopes = [];
  s.local_decls = [];
  s.imported_scopes = [];
}



abstract production mk_decl
d::Decl ::= id::String assoc_scope::Maybe<Decorated Scope>
{
  d.name = id;
  d.assoc_scope = assoc_scope;
}



abstract production mk_ref
r::Ref ::= id::String
{
  r.name = id;
  r.resolutions = [];
}



abstract production mk_imp {- inh: i.other_imps -}
i::Imp ::= id::String
{
  i.name = id;
  i.resolutions = [];
}



{-====================-}



nonterminal Decls;

synthesized attribute decls_list::[Decorated Decl] occurs on Decls;

abstract production decl_cons
dt::Decls ::= d::Decl ds::Decls
{
  propagate parent_scope;
  dt.decls_list = d :: ds.decls_list;
}

abstract production decl_nil
dt::Decls ::= 
{
  dt.decls_list = [];
}



nonterminal Refs;

abstract production ref_cons
rt::Refs ::= r::Ref ds::Refs
{
  propagate parent_scope;
  rt.resolutions = r.resolutions ++ ds.resolutions;
}

abstract production ref_nil
rt::Refs ::= 
{
  rt.resolutions = [];
}



nonterminal Imps;

inherited attribute all_imps::[Decorated Imp] occurs on Imps;
synthesized attribute imps::[Decorated Imp] occurs on Imps;

abstract production imp_cons
it::Imps ::= i::Imp ds::Imps
{
  propagate all_imps, parent_scope;
  it.imps = i :: ds.imps;

  i.other_imps = filter (not_same_imp(i,_), ds.all_imps);
  
  it.imported_scopes = 
    foldl (decls_assoc_scope, [], i.resolutions) ++ ds.imported_scopes;
}

abstract production imp_nil
it::Imps ::= 
{
  it.imps = [];
  it.imported_scopes = [];
}



{-====================-}

function decls_assoc_scope
[Decorated Scope] ::= scopes::[Decorated Scope] decl::Decorated Decl
{
  return case decl.assoc_scope of
    | nothing() -> scopes
    | just(s) -> s :: scopes
  end;
}

function not_same_imp
Boolean ::= i1::Decorated Imp i2::Decorated Imp
{
  return i1.name != i2.name;
}