grammar scope_tree_generic:ast;

imports scope_tree_generic:lmr;


nonterminal Scope;
synthesized attribute id :: Integer occurs on Scope;
synthesized attribute mod_edges :: [Edge] occurs on Scope;
synthesized attribute var_edges :: [Edge] occurs on Scope;
synthesized attribute lex_edges :: [Edge] occurs on Scope;

abstract production mk_scope_generic
top::Scope ::= 
  datum::Maybe<(Datum_Id, Datum)>
  mod_edges :: [Edge]
  var_edges :: [Edge]
  lex_edges :: [Edge]
{
  top.id = genInt ();
  top.mod_edges = mod_edges;
  top.var_edges = var_edges;
  top.lex_edges = lex_edges;
}

abstract production mk_scope
top::Scope ::= 
  mod_edges :: [Edge]
  var_edges :: [Edge]
  lex_edges :: [Edge]
{ forwards to mk_scope_generic (nothing(), mod_edges, var_edges, lex_edges); }

abstract production mk_scope_datum
top::Scope ::= 
  datum::(Datum_Id, Datum)
  mod_edges :: [Edge]
  var_edges :: [Edge]
  lex_edges :: [Edge]
{ forwards to mk_scope_generic (just (datum), mod_edges, var_edges, lex_edges); }


nonterminal Datum;
type Datum_Id = String;

abstract production datum_scope
top::Datum ::= s :: Scope
{}

abstract production datum_type
top::Datum ::= t :: LMR_Type
{}

{-

The productions for Datum should be defined in the object language.

-}




{-

The productions for Identifier should be defined in the object language.

-}