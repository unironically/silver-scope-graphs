grammar scope_tree_generic:ast;

aspect production mk_scope_generic
top::Scope ::= 
  datum::Maybe<(Datum_Id, Datum)>
  mod_edges :: [Edge]
  var_edges :: [Edge]
  lex_edges :: [Edge]
{}

aspect production mk_scope
top::Scope ::= 
  mod_edges :: [Edge]
  var_edges :: [Edge]
  lex_edges :: [Edge]
{}

aspect production mk_scope_datum
top::Scope ::= 
  datum::(Datum_Id, Datum)
  mod_edges :: [Edge]
  var_edges :: [Edge]
  lex_edges :: [Edge]
{}