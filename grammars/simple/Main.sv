grammar simple;

parser parse :: Expr_c {
  simple;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    
    let result::ParseResult<Expr_c> = parse (implode(" ", largs), "<<args>>");
    let ast::Expr = result.parseTree.ast;

    let ty::Type = ast.ty;
    let res::Either<Boolean Integer> = ast.res;

    if result.parseSuccess
      then
        case ty of
            bottom() -> 
              do {print ("ERROR: Ill-typed input program\n"); return -1;}
          | int() -> 
              do {print ("Result: " ++ toString(res.fromRight) ++ "\n"); return 0;}
          | bool() -> 
              do {print ("Result: " ++ toString(res.fromLeft) ++ "\n"); return 0;}
          end
      else 
        do {print ("ERROR: Input string unparsable\n"); return -1;};
  };
}