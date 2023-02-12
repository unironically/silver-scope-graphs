grammar scopegraph;

nonterminal Scope;

nonterminal Decl;
nonterminal Decls;

nonterminal Ref;
nonterminal Refs;

{-====================-}

inherited attribute par::Maybe<Scope> occurs on 
  Scope, Decl, Decls, Ref, Refs;

propagate par on Decls, Refs;

{-====================-}

abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs children::[Scope]
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