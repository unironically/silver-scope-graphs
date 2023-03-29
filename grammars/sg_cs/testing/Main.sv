grammar sg_cs:testing;

imports silver:testing ;

imports sg_cs;

imports scope_tree:ast as sg;
imports scope_tree:visser as res;

parser parse :: Program_c {
  sg_cs;
}


mainTestSuite core_tests ;

-- Tests for understanding the testing framework
equalityTest ( 1 + 10, 4 + 7, Integer, core_tests ) ;
equalityTest ( 31 + 10, 34 + 7 , Integer, core_tests ) ;



{- Example 1
 ----------------------------------------------------------------------
 -}
global e1 :: String = "decls a_1  refs  a_2";

-- Testing the parser
equalityTest (
  parse (e1 , "text" ).parseSuccess, true, Boolean, core_tests );

-- Testing simple resolutions, all_refs, all_dcls
global e1_ast :: Program = parse (e1 , "text" ).parseTree.ast;

equalityTest (bind_ids(e1_ast.ress), 
  [("a_2", "a_1")], 
  [(String,String)], core_tests
);

-- correct ref nodes
equalityTest (ref_ids(e1_ast.graph.sg:all_refs),
  ["a_2"], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (dcl_ids(e1_ast.graph.sg:all_dcls),
  ["a_1"], 
  [String], core_tests
);


{- Example 2
 ----------------------------------------------------------------------
 -}
global e2 :: String = "decls a_1, b_2 refs a_4, a_3, b_5";

equalityTest (
  parse (e2 , "text" ).parseSuccess, true, Boolean, core_tests );

global e2_ast :: Program = parse (e2 , "text" ).parseTree.ast;

-- correct ref nodes
equalityTest (sort (ref_ids(e2_ast.graph.sg:all_refs)),
  ["a_3", "a_4", "b_5"], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (sort (dcl_ids(e2_ast.graph.sg:all_dcls)),
  ["a_1", "b_2"], 
  [String], core_tests
);

-- resolutions on the scope graph
global e2_sg :: Decorated sg:Graph<IdDcl IdRef> = 
  decorate e2_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e2_sg.sg:all_refs))),
  [("a_3", "a_1"), ("a_4", "a_1"), ("b_5", "b_2")], 
  [(String,String)], core_tests
);

-- resolutions on the AST
equalityTest (sort (bind_ids(e2_ast.ress)), 
  [("a_3", "a_1"), ("a_4", "a_1"), ("b_5", "b_2")], 
  [(String,String)], core_tests
);



{- Example 3
 ----------------------------------------------------------------------
 -}
global e3 :: String = "decls a_1, a_2, b_3 refs a_4";

equalityTest (
  parse (e3 , "text" ).parseSuccess, true, Boolean, core_tests );

global e3_ast :: Program = parse (e3 , "text" ).parseTree.ast;

-- correct ref nodes
equalityTest (sort (ref_ids(e3_ast.graph.sg:all_refs)),
  ["a_4"], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (sort (dcl_ids(e3_ast.graph.sg:all_dcls)),
  ["a_1", "a_2", "b_3"], 
  [String], core_tests
);

-- resolutions on the scope graph
global e3_sg :: Decorated sg:Graph<IdDcl IdRef> = 
  decorate e3_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e3_sg.sg:all_refs))),
  [("a_4", "a_1"), ("a_4", "a_2")], 
  [(String,String)], core_tests
);

-- resolutions on the AST
equalityTest (sort (bind_ids(e3_ast.ress)), 
  [("a_4", "a_1"), ("a_4", "a_2")], 
  [(String,String)], core_tests
);


{- Example 4
 ----------------------------------------------------------------------
 -}
global e4 :: String = 
  "module A_2 { decls x_3} import A_5 decls b_1 refs x_4";

equalityTest (
  parse (e4 , "text" ).parseSuccess, true, Boolean, core_tests );

global e4_ast :: Program = parse (e4 , "text" ).parseTree.ast;

-- correct ref nodes
equalityTest (sort (ref_ids(e4_ast.graph.sg:all_refs)),
  ["A_5", "x_4"], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (sort (dcl_ids(e4_ast.graph.sg:all_dcls)),
  ["A_2", "b_1", "x_3"], 
  [String], core_tests
);

-- resolutions on the scope graph
global e4_sg :: Decorated sg:Graph<IdDcl IdRef> = 
  decorate e4_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e4_sg.sg:all_refs))),
  [("A_5", "A_2"), ("x_4", "x_3")], 
  [(String,String)], core_tests
);

-- resolutions on the AST
equalityTest (sort (bind_ids(e4_ast.ress)), 
  [("A_5", "A_2"), ("x_4", "x_3")], 
  [(String,String)], core_tests
);


{- Example 5
 ----------------------------------------------------------------------
  -}
global e5 :: String = 
  "module A_1 { module A_2 { decls a_3} } import A_4 decls b_5 refs a_6";

equalityTest (
  parse (e5 , "text" ).parseSuccess, true, Boolean, core_tests );

global e5_ast :: Program = parse (e5 , "text" ).parseTree.ast;

-- correct ref nodes
equalityTest (sort (ref_ids(e5_ast.graph.sg:all_refs)),
  ["A_4", "a_6"], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (sort (dcl_ids(e5_ast.graph.sg:all_dcls)),
  ["A_1", "A_2", "a_3", "b_5"], 
  [String], core_tests
);

-- resolutions on the scope graph
global e5_sg :: Decorated sg:Graph<IdDcl IdRef> = 
  decorate e5_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e5_sg.sg:all_refs))),
  [("A_4", "A_1")],
  [(String,String)], core_tests
);

-- resolutions on the AST
equalityTest (sort (bind_ids(e5_ast.ress)), 
  [("A_4", "A_1")],
  [(String,String)], core_tests
);


{- Example 6
 ----------------------------------------------------------------------
  -}
global e6 :: String = 
  "module A_1 { module B_2 { decls a_3 refs d_9 } decls d_8 } import A_4 import B_5  decls c_6 refs a_7";

equalityTest (
  parse (e6 , "text" ).parseSuccess, true, Boolean, core_tests );

global e6_ast :: Program = parse (e6 , "text" ).parseTree.ast;

-- correct ref nodes
equalityTest (sort (ref_ids(e6_ast.graph.sg:all_refs)),
  ["A_4", "B_5", "a_7", "d_9" ], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (sort (dcl_ids(e6_ast.graph.sg:all_dcls)),
  ["A_1", "B_2", "a_3", "c_6", "d_8"], 
  [String], core_tests
);

-- resolutions on the scope graph
global e6_sg :: Decorated sg:Graph<IdDcl IdRef> = 
  decorate e6_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e6_sg.sg:all_refs))),
  [("A_4", "A_1"), ("B_5", "B_2"), ("a_7", "a_3"), ("d_9", "d_8")],
  [(String,String)], core_tests
);

-- resolutions on the AST
equalityTest (sort (bind_ids(e6_ast.ress)), 
  [("A_4", "A_1"), ("B_5", "B_2"), ("a_7", "a_3"), ("d_9", "d_8")],
  [(String,String)], core_tests
);


{- Example 7
 ----------------------------------------------------------------------
  -}
global e7 :: String = 
  "module A_1 { module A_2 { decls a_3 } } import A_4 import A_5  decls b_6 refs a_7";

equalityTest (
  parse (e7 , "text" ).parseSuccess, true, Boolean, core_tests );

global e7_ast :: Program = parse (e7 , "text" ).parseTree.ast;

-- correct ref nodes
equalityTest (sort (ref_ids(e7_ast.graph.sg:all_refs)),
  ["A_4", "A_5", "a_7" ], 
  [String], core_tests
);

-- correct dcl nodes
equalityTest (sort (dcl_ids(e7_ast.graph.sg:all_dcls)),
  ["A_1", "A_2", "a_3", "b_6"], 
  [String], core_tests
);

-- resolutions on the scope graph
global e7_sg :: Decorated sg:Graph<IdDcl IdRef> = 
  decorate e7_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e7_sg.sg:all_refs))),
  [("A_4", "A_1"), ("A_5", "A_1")],
  [(String,String)], core_tests
);

-- resolutions on the AST
equalityTest (sort (bind_ids(e7_ast.ress)), 
  [("A_4", "A_1"), ("A_5", "A_1")],
  [(String,String)], core_tests
);




function collect_dcls
[(Decorated sg:Ref<IdDcl IdRef>, Decorated sg:Dcl<IdDcl IdRef>)] ::=
  refs::[Decorated sg:Ref<IdDcl IdRef>]
{
  local res :: [(Decorated sg:Ref<IdDcl IdRef>, 
                 Decorated sg:Dcl<IdDcl IdRef>)] =
     concat (
       map ( \r::Decorated sg:Ref<IdDcl IdRef> ->
               map ( \d::Decorated sg:Dcl<IdDcl IdRef> -> (r,d) , 
                     r.sg:resolutions),  
             refs ) 
          );

  return res;

}

-- Extract identifying strings from Refs and Dcls
function bind_ids
[(String,String)] ::= 
  binds::[(Decorated sg:Ref<IdDcl IdRef>, Decorated sg:Dcl<IdDcl IdRef>)]
{
  return case binds of 
         | [] -> []
         | (r, d)::t -> (r.sg:str_id, d.sg:str_id) :: bind_ids(t)
         end;
}

function ref_ids
[String] ::= 
  refs::[Decorated sg:Ref<IdDcl IdRef>]
{
  return case refs of 
         | [] -> []
         | r::t -> r.sg:str_id :: ref_ids(t)
         end;
}

function dcl_ids
[String] ::= 
  dcls::[Decorated sg:Dcl<IdDcl IdRef>]
{
  return case dcls of 
         | [] -> []
         | d::t -> d.sg:str_id :: dcl_ids(t)
         end;
}


{- Notes

** Object language
** ---------------
- needs a NT for reference and declaration identifiers

- these parameterize the scope tree NTs so that references
  back to the object language AST can be created

- obj lang refs/dcls currently need
  - name : String
  - id : String - which contains the name and index
  - these are scope graph attributes.

  They should/could have
  - name : String - something that yeilds a string
  - index : String - makes refs/dcls with the same name unique
  - id = (name,index) - is unique across ALL refs/dcls
         or the string version of it, now called str_id

  - location : a  where this is some sort of location information
           we'll see what functions we need on this

** Scope Graph AST
** ---------------
- defines NTs like Graph<d r>, Scope<d r>, Dcl<d r>, Ref<d r> etc
- also productions for making the scope tree

- the interface to resolutions
  - all_refs, all_dcls  - on Graph
    collect all Ref and Dcl nodes at the top - raw data

- Dcl and Ref have
  `obj` - 

  `obj` must have name, index, and id


- *** what reference attributes do we have that complete the "graph" ?
  - Refs have `resolutions` - list of visible Dcls
  - Dcls have 'uses` - list of all of its Refs (maybe add this)

  - Scopes? Associated scopes?

  - What ones are drawn by the scope-tree?
  - What ones are drawn by a resolution algorithm?


** To Do
** -----

Can we have an attribute - obj or obj_dcl/ref on Dcl and Ref that
points back to the object language AST node? This node is an argument
to the production.


Minor
- do not overload `d` or `r` as the name of lhs and type of something
  on rhs as was done in mk_decl and is still done in mk_ref


- in Resolution - replace .name with .obj.name
  replace .str_id with .obj.str_id
  but after making some more tests


- should `graph` on SG on Program be decorated?

 -}
