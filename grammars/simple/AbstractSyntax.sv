grammar simple;

nonterminal Expr;

synthesized attribute res::Either<Boolean Integer> occurs on Expr;
synthesized attribute ty::Type occurs on Expr;

{- Boolean arith -}

abstract production not
top::Expr ::= e1::Expr
{
  local e1Ty::Type = e1.ty;

  top.ty = case e1Ty of
             bool() -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(!e1.res.fromLeft)
            end;
}

abstract production and
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (bool(), bool()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(e1.res.fromLeft && e2.res.fromLeft)
            end;
}

abstract production or
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (bool(), bool()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(e1.res.fromLeft || e2.res.fromLeft)
            end;
}

{- Relational arith -}

abstract production lt
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(e1.res.fromRight < e2.res.fromRight)
            end;
}

abstract production gt
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(e1.res.fromRight > e2.res.fromRight)
            end;
}

abstract production leq
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(e1.res.fromRight <= e2.res.fromRight)
            end;
}

abstract production geq
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> left(e1.res.fromRight >= e2.res.fromRight)
            end;
}

abstract production eq
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | (bool(), bool()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case (top.ty, e1.ty) of
              (bottom(), _) -> right(0)
            | (_, int()) -> left(e1.res.fromRight == e2.res.fromRight)
            | (_, bool()) -> left(e1.res.fromLeft == e2.res.fromLeft)
            end;
}

abstract production neq
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | (bool(), bool()) -> bool()
           | _ -> bottom()
           end;
  
  top.res = case (top.ty, e1.ty) of
              (bottom(), _) -> right(0)
            | (_, int()) -> left(e1.res.fromRight != e2.res.fromRight)
            | (_, bool()) -> left(e1.res.fromLeft != e2.res.fromLeft)
            end;
}

{- Integer arith -}

abstract production mul
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(e1.res.fromRight * e2.res.fromRight)
            end;
}

abstract production div
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(e1.res.fromRight / e2.res.fromRight)
            end;
}

abstract production add
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(e1.res.fromRight + e2.res.fromRight)
            end;
}

abstract production sub
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(e1.res.fromRight - e2.res.fromRight)
            end;
}

abstract production neg
top::Expr ::= e1::Expr
{
  local e1Ty::Type = e1.ty;

  top.ty = case (e1Ty) of
             (int()) -> int()
           | _ -> bottom()
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(0 - e1.res.fromRight)
            end;
}

{- Literals -}

abstract production intLit
top::Expr ::= i::Integer
{
  top.ty = int();
  top.res = right(i);
}

abstract production boolLit
top::Expr ::= b::Boolean
{
  top.ty = bool();
  top.res = left(b);
}