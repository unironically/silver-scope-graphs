grammar scopegraph;

nonterminal Graph;
nonterminal Scope;
nonterminal Scopes;

nonterminal Decl;
nonterminal Decls;

nonterminal Ref;
nonterminal Refs;

nonterminal Imps;

{-====================-}

inherited attribute scope_parent :: Maybe<Decorated Scope> occurs on Scope, Scopes;

inherited attribute parent :: Decorated Scope occurs on 
  Decl, Decls, Ref, Refs, Imps;
propagate parent on Decls, Refs, Imps;

synthesized attribute assoc_scope :: Maybe<Decorated Scope> occurs on Decl;
synthesized attribute assoc_decl :: Maybe<Decl> occurs on Scope;

synthesized attribute declsl :: [Decorated Decl] occurs on Scope, Decls;
synthesized attribute refsl :: [Decorated Ref] occurs on Scope, Refs;
synthesized attribute impsl :: [Decorated Ref] occurs on Scope, Imps;
synthesized attribute childrenl :: [Decorated Scope] occurs on Graph, Scope, Scopes;

synthesized attribute res :: [Decorated Decl] occurs on Ref;
synthesized attribute all_res :: [(String, [String])] occurs on Graph, Scope;

{-====================-}

abstract production mk_graph
g::Graph ::= children::Scopes
{
  g.childrenl = children.childrenl;
  children.scope_parent = nothing();

  g.all_res = foldl (
    (\acc::[(String, [String])] s::Decorated Scope
      -> acc ++ s.all_res), [], g.childrenl);
}

{-====================-}

abstract production mk_scope
s::Scope ::= decls::Decls refs::Refs imps::Imps children::Scopes
{
  forwards to mk_scope_real (decls, refs, imps, children, nothing());
}

abstract production mk_scope_assoc
s::Scope ::= decls::Decls refs::Refs imps::Imps children::Scopes assoc_decl::Decl
{
  forwards to mk_scope_real (decls, refs, imps, children, just(assoc_decl));
}

abstract production mk_scope_real
s::Scope ::= decls::Decls refs::Refs imps::Imps children::Scopes assoc_decl::Maybe<Decl>
{
  s.declsl = decls.declsl;
  s.refsl = refs.refsl;
  s.impsl = imps.impsl;
  s.childrenl = children.childrenl;

  decls.parent = s;
  refs.parent = s;
  imps.parent = s;
  children.scope_parent = just (s);

  s.all_res = 
    foldl (
      (\acc::[(String, [String])] r::Decorated Ref
        -> (r.str, map ((\d::Decorated Decl -> d.str), r.res)) :: acc), 
      [], s.refsl ++ s.impsl
    ) ++
    foldl (
      (\acc::[(String, [String])] s::Decorated Scope -> acc ++ s.all_res),
      [], s.childrenl
    );

  s.assoc_decl = assoc_decl;
}

abstract production mk_decl
d::Decl ::= id::String
{
  d.assoc_scope = nothing();
}

abstract production mk_decl_assoc
d::Decl ::= id::String s::Scope
{
  s.scope_parent = just(d.parent);
  d.assoc_scope = just(s);
}

abstract production mk_ref
r::Ref ::= id::String
{
  r.res = resolve_visser([], r);
}

{-====================-}

abstract production scope_cons
st::Scopes ::= s::Scope ss::Scopes
{
  st.childrenl = s :: ss.childrenl;
  s.scope_parent = st.scope_parent;
  ss.scope_parent = st.scope_parent;
}

abstract production scope_nil
st::Scopes ::=
{
  st.childrenl = [];
}

abstract production decl_cons
dt::Decls ::= d::Decl ds::Decls
{
  dt.declsl = d :: ds.declsl;
}

abstract production decl_nil
dt::Decls ::= 
{
  dt.declsl = [];
}

abstract production ref_cons
rt::Refs ::= r::Ref rs::Refs
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

function combine_scopes
Scopes ::= ss1::Scopes ss2::Scopes
{
  return
    case ss1 of
    | scope_nil () -> ss2
    | scope_cons (s, st) -> scope_cons (s, combine_scopes (st, ss2))
  end;
}
