grammar scopegraph;

parser parse :: Program_c {
  scopegraph;
}

function main
IO<Integer> ::= largs::[String]
{
  local args :: String = head(largs);
  local result :: ParseResult<Program_c> = parse (args, "<<args>>");
  local r_cst :: Program_c = result.parseTree;
  local sg :: Decorated Scope = r_cst.scope_c;

  return if result.parseSuccess
    then do {print ("Success!\n" ++ graphviz_draw_graph(sg) ++ "\n"); return 0;}
    else do {print ("Failure!\n"); return 0;};
}