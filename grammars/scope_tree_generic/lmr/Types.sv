nonterminal LMR_Type;

abstract production rec_type
top::LMR_Type ::= s::Scope
{}

abstract production int_type
top::LMR_Type ::= 
{}

abstract production bool_type
top::LMR_Type ::=
{}

abstract production fun_type
top::LMR_Type ::=
  t1 :: LMR_Type
  t2 :: LMR_Type
{}