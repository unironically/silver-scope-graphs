grammar statixgraph;

synthesized attribute ast<a> :: a;

nonterminal Graph_c with ast<Graph>;

concrete production graph_c
top::Graph_c ::=
  scopes::ScopeAsserts_c
{ top.ast = graph(scopes.ast); }

nonterminal ScopeAsserts_c with ast<ScopeAsserts>;

concrete production consScopeAsserts_c
top::ScopeAsserts_c ::=
  h::ScopeAssert_c t::ScopeAsserts_c
{ top.ast = consScopeAsserts(h.ast, t.ast); }

concrete production oneScopeAsserts_c
top::ScopeAsserts_c ::= 
  h::ScopeAssert_c
{ top.ast = oneScopeAsserts (h.ast); }


nonterminal ScopeAssert_c with ast<ScopeAssert>;

concrete production scopeAssert_c
top::ScopeAssert_c ::= 
  'new' id::Int_t '->' datum::DatumAssert_c edges::EdgeAsserts_c
{ 
  local num::Integer = case toIntSafe (id.lexeme) of
                         just (i) -> i
                       | nothing () -> -1
                       end;
  top.ast = scopeAssert(num, datum.ast, edges.ast); 
}

nonterminal DatumAssert_c with ast<DatumAssert>;

concrete production datumAssertNothing_c
top::DatumAssert_c ::=
  '(' ')'
{ top.ast = datumAssertNothing(); }

concrete production datumAssertNameTy_c
top::DatumAssert_c ::=
  '(' '"' name::Id_t  '"' ',' ty::Ty_t '(' ')' ')'
{ top.ast = datumAssertNameTy(name.lexeme, ty.lexeme); }

nonterminal EdgeAsserts_c with ast<EdgeAsserts>;

concrete production consEdgeAsserts_c
top::EdgeAsserts_c ::=
  h::EdgeAssert_c t::EdgeAsserts_c
{ top.ast = consEdgeAsserts(h.ast, t.ast); }

concrete production nilEdgeAsserts_c
top::EdgeAsserts_c ::=
{ top.ast = nilEdgeAsserts(); }

nonterminal EdgeAssert_c with ast<EdgeAssert>;

concrete production edgeAssert_c
top::EdgeAssert_c ::=
  '-[' edge::Ty_t ']->' tgt::Int_t
{
  local num::Integer = case toIntSafe (tgt.lexeme) of
                         just (i) -> i
                       | nothing () -> -1
                       end;
  top.ast = edgeAssert (edge.lexeme, num); 
}