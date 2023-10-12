grammar simple;

nonterminal Prog;
nonterminal Expr;

synthesized attribute res::Either<Boolean Integer> occurs on Prog, Expr;
synthesized attribute ty::Type occurs on Prog, Expr;

synthesized attribute aterm::String occurs on Prog, Expr;

{- Program -}
abstract production prog
top::Prog ::= e::Expr
{
  top.aterm = "Expr (" ++ e.aterm ++ ")";
  top.ty = e.ty;
  top.res = e.res;
}

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

  top.aterm = "Not (" ++ e1.aterm ++ ")";
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

  top.aterm = "And (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Or (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Lt (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Gt (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Leq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Geq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production equal
top::Expr ::= e1::Expr e2::Expr
{
  top.ty = if e1.ty == e2.ty
             then bool ()
             else bottom ();
  
  top.res = case (top.ty, e1.ty) of
              (bottom(), _) -> right(0)
            | (_, int()) -> left(e1.res.fromRight == e2.res.fromRight)
            | (_, bool()) -> left(e1.res.fromLeft == e2.res.fromLeft)
            end;

  top.aterm = "Eq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production notequal
top::Expr ::= e1::Expr e2::Expr
{
  top.ty = if e1.ty == e2.ty
             then bool ()
             else bottom ();
  
  top.res = case (top.ty, e1.ty) of
              (bottom(), _) -> right(0)
            | (_, int()) -> left(e1.res.fromRight != e2.res.fromRight)
            | (_, bool()) -> left(e1.res.fromLeft != e2.res.fromLeft)
            end;

  top.aterm = "Neq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

{- Integer arith -}

abstract production mul
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> error("Tried to use mul with a non-integer type!")
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(e1.res.fromRight * e2.res.fromRight)
            end;

  top.aterm = "Mul (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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
  
  top.aterm = "Div (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production add
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> error("Tried to use add with a non-integer type!")
           end;

  top.res = case top.ty of
              bottom() -> right(0)
            | _ -> right(e1.res.fromRight + e2.res.fromRight)
            end;

  top.aterm = "Add (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Sub (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
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

  top.aterm = "Neg (" ++ e1.aterm ++ ")";
}

{- Literals -}

abstract production intLit
top::Expr ::= i::Integer
{
  top.ty = int();
  top.res = right(i);
  top.aterm = "Int (\"" ++ toString(i) ++ "\")";
}

abstract production trueLit
top::Expr ::=
{
  top.ty = bool();
  top.res = left(true);
  top.aterm = "True ()";
}

abstract production falseLit
top::Expr ::=
{
  top.ty = bool();
  top.res = left(false);
  top.aterm = "False ()";
}