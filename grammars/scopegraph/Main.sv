grammar scopegraph;

parser parse :: Program_c {
  scopegraph;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    let filePath :: String = head(largs);
    file :: String <- readFile(head(largs));

    let fileNameExt :: String = last(explode("/", filePath));
    let fileName :: String = head(explode(".", fileNameExt));
    
    let result :: ParseResult<Program_c> = parse (file, filePath);
    let r_cst :: Program_c = result.parseTree;
    let sg :: Decorated Graph = r_cst.graph_c;
    
    let drawn :: String = graphviz_draw_graph(sg);
    system ("echo '" ++ drawn ++ "' | dot -Tsvg > sg_" ++ fileName ++ ".svg");
    
    if result.parseSuccess
      then do {print ("Success: see sg_" ++ fileName ++ ".svg\n"); return 0;}
      else do {print ("Failure!\n"); return -1;};
  };
}