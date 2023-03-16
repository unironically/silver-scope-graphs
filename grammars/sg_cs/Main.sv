grammar sg_cs;

imports scope_tree:ast as sg;

parser parse :: Program_c {
  sg_cs;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    let filePath :: String = head(largs);
    file :: String <- readFile(head(largs));

    let fileNameExt :: String = last(explode("/", filePath));
    let outFileName :: String = "sg_" ++ head(explode(".", fileNameExt)) ++ ".svg";
    
    let result :: ParseResult<Program_c> = parse (file, filePath);

    let ast :: Program = result.parseTree.ast;
    let graph :: sg:Graph<IdDecl IdRef> = result.parseTree.ast.graph;

    system ("echo '" ++ graph.sg:string ++ "' | dot -Tsvg > " ++ outFileName);
    
    if result.parseSuccess
      then do {print ("Success!\n" ++ str_binds(ast.ress)); return 0;}
      else do {print ("Failure!\n"); return -1;};
  };
}

function str_binds
String ::= binds::[(String, String)]
{
  return foldl ((\acc::String b::(String, String) -> acc ++ " - " ++ fst(b) ++ " -> " ++ snd(b) ++ "\n"), "", binds);
}
