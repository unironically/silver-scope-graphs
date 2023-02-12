grammar scopegraph;

nonterminal Scope;

nonterminal Decl;
nonterminal Decls;

nonterminal Ref;
nonterminal Refs;

nonterminal Imps;

{-====================-}

inherited attribute scope_parent :: Maybe<Scope> occurs on Scope;

inherited attribute parent :: Decorated Scope occurs on 
  Decl, Decls, Ref, Refs, Imps;
propagate parent on Decls, Refs, Imps;

synthesized attribute id :: Integer occurs on Scope;
synthesized attribute name :: String occurs on Ref, Decl;
synthesized attribute assoc_scope :: Maybe<Scope> occurs on Decl;
synthesized attribute children :: [Decorated Scope] occurs on Scope;

synthesized attribute declsl :: [Decorated Decl] occurs on Scope, Decls;
synthesized attribute refsl :: [Decorated Ref] occurs on Scope, Refs;
synthesized attribute impsl :: [Ref] occurs on Scope, Imps;

{-====================-}

abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs imps::Imps children::[Decorated Scope]
{
  s.id = genInt();
  s.declsl = decls.declsl;
  s.refsl = refs.refsl;
  s.impsl = imps.impsl;
  s.children = children;
}

abstract production mk_decl
d::Decl ::= id::String assoc_scope::Maybe<Scope>
{
  d.name = id;
  d.assoc_scope = assoc_scope;
}

abstract production mk_ref
r::Ref ::= id::String
{
  r.name = id;
}

{-====================-}

abstract production decl_cons
dt::Decls ::= d::Decorated Decl ds::Decls
{
  dt.declsl = d :: ds.declsl;
}

abstract production decl_nil
dt::Decls ::= 
{
  dt.declsl = [];
}

abstract production ref_cons
rt::Refs ::= r::Decorated Ref rs::Refs
{
  rt.refsl = r :: rs.refsl;
}

abstract production ref_nil
rt::Refs ::= 
{
  rt.refsl = [];
}

abstract production imp_cons
it::Imps ::= i::Ref is::Imps
{
  it.impsl = i :: is.impsl;
}

abstract production imp_nil
it::Imps ::= 
{
  it.impsl = [];
}