grammar scopegraph;

nonterminal Graph;
nonterminal Scope;

nonterminal Decl;
nonterminal Decls;

nonterminal Ref;
nonterminal Refs;

nonterminal Imps;

{-====================-}

inherited attribute scope_parent :: Maybe<Decorated Scope> occurs on Scope;

inherited attribute parent :: Decorated Scope occurs on 
  Decl, Decls, Ref, Refs, Imps;
propagate parent on Decls, Refs, Imps;

synthesized attribute id :: Integer occurs on Scope;
synthesized attribute name :: String occurs on Scope, Ref, Decl;
synthesized attribute str :: String occurs on Ref, Decl;
synthesized attribute substr :: String occurs on Ref, Decl;
synthesized attribute assoc_scope :: Maybe<Decorated Scope> occurs on Decl;
synthesized attribute children :: [Decorated Scope] occurs on Graph, Scope;

synthesized attribute declsl :: [Decorated Decl] occurs on Scope, Decls;
synthesized attribute refsl :: [Decorated Ref] occurs on Scope, Refs;
synthesized attribute impsl :: [Decorated Ref] occurs on Scope, Imps;

synthesized attribute res :: [Decorated Decl] occurs on Ref;

{-====================-}

abstract production mk_graph
g::Graph ::= children::[Decorated Scope]
{
  g.children = children;
}

{-====================-}

abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs imps::Imps children::[Decorated Scope]
{
  s.declsl = decls.declsl;
  s.refsl = refs.refsl;
  s.impsl = imps.impsl;
  s.children = children;
  s.id = genInt();
  s.name = toString(s.id);
}

abstract production mk_decl
d::Decl ::= id::String assoc_scope::Maybe<Decorated Scope>
{
  local parts::[String] = explode ("_", id);
  d.str = id;
  d.name = head(parts);
  d.substr = head(tail(parts));
  d.assoc_scope = assoc_scope;
}

abstract production mk_ref
r::Ref ::= id::String
{
  local parts::[String] = explode ("_", id);
  r.str = id;
  r.name = head(parts);
  r.substr = head(tail(parts));
  r.res = resolve_visser([], r);
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
it::Imps ::= i::Decorated Ref is::Imps
{
  it.impsl = i :: is.impsl;
}

abstract production imp_nil
it::Imps ::= 
{
  it.impsl = [];
}

{-====================-}

function combine_decls
Decls ::= ds1::Decls ds2::Decls
{
  return
    case ds1 of
    | decl_nil () -> ds2
    | decl_cons (d, dt) -> decl_cons (d, combine_decls (dt, ds2))
    end;
}

function combine_refs
Refs ::= rs1::Refs rs2::Refs
{
  return
    case rs1 of
    | ref_nil () -> rs2
    | ref_cons (r, rt) -> ref_cons (r, combine_refs (rt, rs2))
    end;
}