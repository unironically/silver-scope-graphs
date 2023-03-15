grammar sg_cs;

parser parse :: Program_c {
  sg_cs;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    let filePath :: String = head(largs);
    file :: String <- readFile(head(largs));

    --let fileNameExt :: String = last(explode("/", filePath));
    --let fileName :: String = head(explode(".", fileNameExt));
    
    let result :: ParseResult<Program_c> = parse (file, filePath);

    --let sg :: Graph_sg = result.parseTree.ast.graph;

    --system ("echo '" ++ sg.string ++ "' | dot -Tsvg > sg_" ++ fileName ++ ".svg");
    
    if result.parseSuccess
      then do {print ("Success!\n"); return 0;}
      else do {print ("Failure!\n"); return -1;};
  };
}
