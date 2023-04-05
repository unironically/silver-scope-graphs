grammar sg_cs:driver;

imports sg_cs:lang;

-- import the grammar for making scope trees
-- currenlty this includes the resolution algorithm
imports scope_tree:ast as sg;
imports scope_tree:visser as res;

parser parse :: Program_c {
  sg_cs:lang;
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
    let graph :: sg:Graph<IdDcl IdRef> = result.parseTree.ast.graph;

    system ("echo '" ++ graph.sg:string ++ "' | dot -Tsvg > " ++ outFileName);
    
    if result.parseSuccess
      then do {print ("Success!\n" ++ str_binds(ast.ress)); return 0;}
      else do {print ("Failure!\n"); return -1;};
  };
}

function str_binds
String ::= binds::[(Decorated sg:Ref<IdDcl IdRef>, Decorated sg:Dcl<IdDcl IdRef>)]
{
  return case binds of 
         | [] -> ""
         | (r, d)::t -> r.sg:str_id ++ " -> " ++ d.sg:str_id ++ "\n" ++ str_binds(t)
         end;
}
