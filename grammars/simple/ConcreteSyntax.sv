grammar simple;

nonterminal Expr_c;

synthesized attribute ast::Expr occurs on Expr_c;

{- Boolean arith -}

concrete production not_c
top::Expr_c ::= '!' e1::Expr_c
{
  top.ast = not(e1.ast);
}

concrete production and_c
top::Expr_c ::= e1::Expr_c '&' e2::Expr_c
{
  top.ast = and(e1.ast, e2.ast);
}

concrete production or_c
top::Expr_c ::= e1::Expr_c '|' e2::Expr_c
{
  top.ast = or(e1.ast, e2.ast);
}

{- Relational arith -}

concrete production lt_c
top::Expr_c ::= e1::Expr_c '<' e2::Expr_c
{
  top.ast = lt(e1.ast, e2.ast);
}

concrete production gt_c
top::Expr_c ::= e1::Expr_c '>' e2::Expr_c
{
  top.ast = gt(e1.ast, e2.ast);
}

concrete production leq_c
top::Expr_c ::= e1::Expr_c '<=' e2::Expr_c
{
  top.ast = leq(e1.ast, e2.ast);
}

concrete production geq_c
top::Expr_c ::= e1::Expr_c '>=' e2::Expr_c
{
  top.ast = geq(e1.ast, e2.ast);
}

concrete production eq_c
top::Expr_c ::= e1::Expr_c '==' e2::Expr_c
{
  top.ast = eq(e1.ast, e2.ast);
}

concrete production neq_c
top::Expr_c ::= e1::Expr_c '!=' e2::Expr_c
{
  top.ast = neq(e1.ast, e2.ast);
}

{- Integer arith -}

concrete production mul_C
top::Expr_c ::= e1::Expr_c '*' e2::Expr_c
{
  top.ast = mul(e1.ast, e2.ast);
}

concrete production div_c
top::Expr_c ::= e1::Expr_c '/' e2::Expr_c
{
  top.ast = div(e1.ast, e2.ast);
}

concrete production add_c
top::Expr_c ::= e1::Expr_c '+' e2::Expr_c
{
  top.ast = add(e1.ast, e2.ast);
}

concrete production sub_c
top::Expr_c ::= e1::Expr_c '-' e2::Expr_c
{
  top.ast = sub(e1.ast, e2.ast);
}

concrete production neg_c
top::Expr_c ::= '-' e1::Expr_c
{
  top.ast = neg(e1.ast);
}

{- Literals -}

concrete production intLit_c
top::Expr_c ::= i::Int_t
{
  local num::Integer = case toIntSafe (i.lexeme) of
                         just (i) -> i
                       | nothing () -> -1
                       end;
  top.ast = intLit(num);
}

concrete production trueLit_c
top::Expr_c ::= b::True_t
{
  top.ast = boolLit(true);
}

concrete production falseLit_c
top::Expr_c ::= b::False_t
{
  top.ast = boolLit(false);
}