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

{-====================-}

abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs imps::Imps children::[Scope]
{
}

abstract production mk_decl
d::Decl ::= id::String assoc_scope::Maybe<Decorated Scope>
{
}

abstract production mk_ref
r::Ref ::= id::String
{
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