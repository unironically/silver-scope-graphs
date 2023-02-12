grammar scopegraph;

nonterminal Scope;

nonterminal Decl;
nonterminal Decls;

nonterminal Ref;
nonterminal Refs;

nonterminal Imps;

{-====================-}

inherited attribute parent::Maybe<Scope> occurs on 
  Scope, Decl, Decls, Ref, Refs, Imps;
propagate parent on Decls, Refs, Imps;

synthesized attribute name::String occurs on Ref, Decl;
synthesized attribute assoc_scope :: Maybe<Scope> occurs on Decl;

{-====================-}

abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs imps::Imps children::[Scope]
{
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
dt::Decls ::= d::Decl ds::Decls
{
}

abstract production decl_nil
dt::Decls ::= 
{
}

abstract production ref_cons
rt::Refs ::= r::Ref ds::Refs
{
}

abstract production ref_nil
rt::Refs ::= 
{
}

abstract production imp_cons
it::Imps ::= i::Ref ds::Imps
{
}

abstract production imp_nil
it::Imps ::= 
{
}