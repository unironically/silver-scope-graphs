grammar scope_tree_generic:ast;

nonterminal Scope;

abstract production mk_scope_generic
top::Scope ::= label::Integer datum::Maybe<(Identifier, Datum)>
{}

abstract production mk_scope
top::Scope ::= label::Integer
{ forwards to mk_scope_generic (label, nothing()); }

abstract production mk_scope_datum
top::Scope ::= label::Integer datum::(Identifier, Datum)
{ forwards to mk_scope_generic (label, just (datum)); }


nonterminal Datum;

{-

The productions for Datum should be defined in the object language.

-}


nonterminal Identifier;

{-

The productions for Identifier should be defined in the object language.

-}