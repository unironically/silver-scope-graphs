grammar scopegraph;

parser parse :: Program_c {
  scopegraph;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    let fileName :: String = head(largs);
    file :: String <- readFile(head(largs));
    
    let result :: ParseResult<Program_c> = parse (file, fileName);
    let r_cst :: Program_c = result.parseTree;
    let sg :: Decorated Graph = r_cst.graph_c;
    
    graphviz_printed :: Integer <- 
      system ("echo '" ++ graphviz_draw_graph(sg) ++ "' | dot -Tsvg > scope_graph.svg");
    
    if result.parseSuccess
      then do {print ("Success!\n"); return 0;}
      else do {print ("Failure!\n"); return -1;};
  };
}