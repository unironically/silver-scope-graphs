grammar lmr:driver;

imports lmr:lang;

parser parse :: Program_c {
  lmr:lang;
}

function main
IO<Integer> ::= largs::[String]
{
  return do {
    
    let filePath :: String = head(largs);
    file :: String <- readFile(head(largs));

    let result :: ParseResult<Program_c> = parse (file, filePath);
    let ast :: Program = result.parseTree.ast;

    if result.parseSuccess
      then do {print ("Success!\n" ++ ast.pp); return 0;}
      else do {print ("Failure!\n"); return -1;};

  };
}