grammar scope_tree_generic:ast;

nonterminal Scope;

abstract production mk_scope_generic
top::Scope ::= 
  label::Integer 
  datum::Maybe<(Identifier, Datum)>
  edges::Edges
{}

abstract production mk_scope
top::Scope ::= 
  label::Integer
  edges::Edges
{ forwards to mk_scope_generic (label, nothing(), edges); }

abstract production mk_scope_datum
top::Scope ::= 
  label::Integer 
  datum::(Identifier, Datum)
  edges::Edges
{ forwards to mk_scope_generic (label, just (datum), edges); }


nonterminal Datum;

{-

The productions for Datum should be defined in the object language.

-}


nonterminal Identifier;

{-

The productions for Identifier should be defined in the object language.

-}