grammar simpleseqlet;

parser parse :: Prog_c {
  simpleseqlet;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    
    let result::ParseResult<Prog_c> = parse (implode(" ", largs), "<<args>>");
    let ast::Prog = result.parseTree.ast;

    let ty::Type = ast.ty;
    let res::Either<Boolean Integer> = ast.res;

    if result.parseSuccess
      then
        case ty of
            bottom() -> 
              err_out ("Ill-typed input program")
          | int() -> 
              output_and_test(toString(res.fromRight), ast)
          | bool() -> 
              output_and_test(toString(res.fromLeft), ast)
          end
      else 
        err_out ("Input unparsable");
  };
}

fun output_and_test IO<Integer> ::= resString::String ast::Prog =
  do {print ( "----------Silver out:----------\n" ++
              "- Result: " ++ resString ++ 
              "\n- Aterm: " ++ ast.aterm ++ 
              "\n- Running aterm with Ministatix...\n" ++
              "----------Statix out:----------\n"); 
      writeFile ("expr.aterm", ast.aterm);
      system ("./mstx.sh expr.aterm");
      print ("-------------------------------\n");
      deleteFile("expr.aterm");
      return 0;};

fun err_out IO<Integer> ::= errString::String =
  do {print ("----------Silver out:----------\n" ++
             "- ERROR: " ++ errString ++
             "\n-------------------------------\n"); 
      return -1;};