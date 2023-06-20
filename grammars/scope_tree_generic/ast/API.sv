grammar scope_tree_generic:ast;

{- Scopes -}

-- No datum / ()
aspect production mk_scope
top::Scope ::= 
  label::Integer
  edges::Edges
{}

-- Identifier and datum
aspect production mk_scope_datum
top::Scope ::= 
  label::Integer 
  datum::(Identifier, Datum)
  edges::Edges
{}

{- Edges -}

aspect production mk_edge
top::Edge ::= 
  src::Scope 
  label::Label 
  dst::Scope
{}