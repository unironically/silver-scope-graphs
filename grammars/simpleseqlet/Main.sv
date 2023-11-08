grammar simpleseqlet;

imports statixgraph hiding Keyword;

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

    if result.parseSuccess
      then
        case ty of
            bottom() -> 
              err_out ("Ill-typed input program")
          | int() -> 
              output_and_test(ast)
          | bool() -> 
              output_and_test(ast)
          end
      else 
        err_out ("Input unparsable");
  };
}

fun output_and_test IO<Integer> ::= ast::Prog =
  do {print ( "----------Silver out:----------\n" ++
              "\n- Aterm: " ++ ast.aterm ++ 
              "\n- Running aterm with Ministatix...\n" ++
              "----------Statix out:----------\n"); 
      writeFile ("expr.aterm", ast.aterm);
      system ("./mstx.sh expr.aterm");
      print ("-------------------------------\n");
      deleteFile("expr.aterm");

      {- Statix graph to graphviz drawing: -}

      system ("sed '0,/^Graph:$/d' mstx.out > graph.out");

      let filePath :: String = "graph.out";
      file :: String <- readFile("graph.out");

      let result::ParseResult<Graph_c> = statixgraph:parse(file, filePath);
      let graph::Graph = result.parseTree.ast;

      let outFileName :: String = "sg_statix.svg";
      system ("echo '" ++ graph.string ++ "' | dot -Tsvg > " ++ outFileName);

      {- Silver graph to graphviz drawing: -}

      let outFileName :: String = "sg_silver.svg";
      system ("echo '" ++ ast.string ++ "' | dot -Tsvg > " ++ outFileName);

      return 0;};

fun err_out IO<Integer> ::= errString::String =
  do {print ("----------Silver out:----------\n" ++
             "- ERROR: " ++ errString ++
             "\n-------------------------------\n"); 
      return -1;};