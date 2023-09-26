nonterminal LMR_Type;

synthesized attribute str::String occurs on LMR_Type;

abstract production rec_type
top::LMR_Type ::= s::Scope
{ top.str = "rec"; }

abstract production int_type
top::LMR_Type ::= 
{ top.str = "int"; }

abstract production bool_type
top::LMR_Type ::=
{ top.str = "bool"; }

abstract production fun_type
top::LMR_Type ::=
  t1 :: LMR_Type
  t2 :: LMR_Type
{ top.str = "fun"; }

abstract production err_ty
top::LMR_Type ::=
{ top.str = "err"; }