grammar simpleseqlet;

nonterminal Type with simpleseqlet:scopegraphs:string;

abstract production int
top::Type ::=
{
  top.string = "INT";
}

abstract production bool
top::Type ::=
{
  top.string = "BOOL";
}

abstract production bottom
top::Type ::=
{
  top.string = "BOTTOM";
}

instance Eq Type {
  eq = tyEq;
  neq = tyNeq;
}

function tyEq
Boolean ::= t1::Type t2::Type
{
  return case (t1, t2) of
           (int (), int ()) -> true
         | (bool (), bool ()) -> true
         | _ -> false
         end;
}

function tyNeq
Boolean ::= t1::Type t2::Type
{
  return !(tyEq (t1, t2));
}