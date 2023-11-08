grammar statixgraph;

parser parse :: Graph_c {
  statixgraph;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    
    let filePath :: String = head(largs);
    file :: String <- readFile(head(largs));

    let result::ParseResult<Graph_c> = parse (file, filePath);
    let graph::Graph = result.parseTree.ast;

    let outFileName :: String = "sg_statix.svg";

    system ("echo '" ++ graph.string ++ "' | dot -Tsvg > " ++ outFileName);

    if result.parseSuccess
      then do {print ("Parse success!\n"); return 0;}
      else do {print ("Parse failure!\n"); return -1;};

  };
}