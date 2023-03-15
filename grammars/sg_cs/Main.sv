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

    let graph :: sg:Graph<Name> = result.parseTree.ast.graph;

    system ("echo '" ++ graph.sg:string ++ "' | dot -Tsvg > " ++ outFileName);
    
    if result.parseSuccess
      then do {print ("Success! See " ++ outFileName ++ " for scope graph illustration. \n"); return 0;}
      else do {print ("Failure!\n"); return -1;};
  };
}
