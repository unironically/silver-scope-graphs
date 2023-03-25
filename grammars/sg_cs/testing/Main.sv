grammar sg_cs:testing;

imports silver:testing ;
imports sg_cs;

imports scope_tree:ast as sg;

parser parse :: Program_c {
  sg_cs;
}

mainTestSuite core_tests ;


equalityTest ( 1 + 10, 4 + 7, Integer, core_tests ) ;
equalityTest ( 31 + 10, 34 + 7 , Integer, core_tests ) ;

-- testing the parser
global e1 :: String = "decls a_1  refs  a_2";

equalityTest (
  parse (e1 , "text" ).parseSuccess, true, Boolean, core_tests );



-- testing resolutions
global e1_ast :: Program = parse (e1 , "text" ).parseTree.ast;

equalityTest (
  bind_ids(e1_ast.ress), 
  [("a_2", "a_1")], 
  [(String,String)], core_tests
);



-- Extract identifying strings from Refs and Decls
function bind_ids
[(String,String)] ::= 
  binds::[(Decorated sg:Ref<IdDecl IdRef>, Decorated sg:Decl<IdDecl IdRef>)]
{
  return case binds of 
         | [] -> []
         | (r, d)::t -> (r.sg:id, d.sg:id) :: str_binds(t)
         end;
}
