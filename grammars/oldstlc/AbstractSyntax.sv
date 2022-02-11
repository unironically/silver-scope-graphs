grammar oldstlc;

synthesized attribute pp::String;
inherited attribute declref:: Decorated Term;

nonterminal Term with pp, declref;

abstract production var
top::Term ::= id::String
{
  top.pp = "ref(" ++ id ++ ")";
}

abstract production abs
top::Term ::= id::String body::Term
{
  top.pp = "abs(" ++ id ++ ", " ++ body.pp ++ ")";
}

abstract production app
top::Term ::= t1::Term t2::Term
{
  top.pp = "app(" ++ t1.pp ++ ", " ++ t2.pp ++ ")";
}

-- Scope graph stuff

synthesized attribute parent::Maybe<Scope>;
synthesized attribute declarations::[String];
synthesized attribute references::[String];
synthesized attribute imports::[String];

nonterminal Scope with parent, declarations, references, imports;

abstract production scope
top::Scope ::= s::Maybe<Scope> d::[String] r::[String] i::[String]
{
  top.parent = s;
  top.declarations = d;
  top.references = r;
  top.imports = i;
}

-- Contruct scope graph

function constructGraph
[Scope] ::= t::Term
{
  return let ns::Scope = scope(nothing(), [], [], []) in constructGraph_helper(ns, [ns], t) end;
}

function constructGraph_helper
[Scope] ::= cs::Scope sl::[Scope] t::Term
{
  local attribute csn::[Scope] = case t of
  | abs(v, b) -> sl
  | app(l, r) -> sl
  | var(x) -> scope(cs.parent, cs.declarations, x::cs.references, cs.imports)::sl
  end;
  return csn;
}
