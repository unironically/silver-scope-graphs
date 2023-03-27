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


-- Testing the parser
global e1 :: String = "decls a_1  refs  a_2";

equalityTest (
  parse (e1 , "text" ).parseSuccess, true, Boolean, core_tests );


-- Testing simple resolutions, all_refs, all_dcls
global e1_ast :: Program = parse (e1 , "text" ).parseTree.ast;

equalityTest (bind_ids(e1_ast.ress), 
  [("a_2", "a_1")], 
  [(String,String)], core_tests
);

equalityTest (ref_ids(e1_ast.graph.sg:all_refs),
  ["a_2"], 
  [String], core_tests
);

equalityTest (dcl_ids(e1_ast.graph.sg:all_dcls),
  ["a_1"], 
  [String], core_tests
);


{- Example 2 -}
global e2 :: String = "decls a_1, b_2 refs a_4, a_3, b_5";

equalityTest (
  parse (e2 , "text" ).parseSuccess, true, Boolean, core_tests );

global e2_ast :: Program = parse (e2 , "text" ).parseTree.ast;

-- resolutions on the AST
equalityTest (sort (bind_ids(e2_ast.ress)), 
  [("a_3", "a_1"), ("a_4", "a_1"), ("b_5", "b_2")], 
  [(String,String)], core_tests
);

-- resolutions on the scope graph
global e2_sg :: Decorated sg:Graph<IdDecl IdRef> = 
  decorate e2_ast.graph with {} ;

equalityTest (sort (bind_ids ( collect_dcls (e2_sg.sg:all_refs))),
  [("a_3", "a_1"), ("a_4", "a_1"), ("b_5", "b_2")], 
  [(String,String)], core_tests
);

equalityTest (sort (ref_ids(e2_ast.graph.sg:all_refs)),
  ["a_3", "a_4", "b_5"], 
  [String], core_tests
);

equalityTest (sort (dcl_ids(e2_ast.graph.sg:all_dcls)),
  ["a_1", "b_2"], 
  [String], core_tests
);



function collect_dcls
[(Decorated sg:Ref<IdDecl IdRef>, Decorated sg:Decl<IdDecl IdRef>)] ::=
  refs::[Decorated sg:Ref<IdDecl IdRef>]
{
  local res :: [(Decorated sg:Ref<IdDecl IdRef>, 
                 Decorated sg:Decl<IdDecl IdRef>)] =
     concat (
       map ( \r::Decorated sg:Ref<IdDecl IdRef> ->
               map ( \d::Decorated sg:Decl<IdDecl IdRef> -> (r,d) , 
                     r.sg:resolutions),  
             refs ) 
          );

  return res;

}

-- Extract identifying strings from Refs and Decls
function bind_ids
[(String,String)] ::= 
  binds::[(Decorated sg:Ref<IdDecl IdRef>, Decorated sg:Decl<IdDecl IdRef>)]
{
  return case binds of 
         | [] -> []
         | (r, d)::t -> (r.sg:str_id, d.sg:str_id) :: bind_ids(t)
         end;
}

function ref_ids
[String] ::= 
  refs::[Decorated sg:Ref<IdDecl IdRef>]
{
  return case refs of 
         | [] -> []
         | r::t -> r.sg:str_id :: ref_ids(t)
         end;
}

function dcl_ids
[String] ::= 
  dcls::[Decorated sg:Decl<IdDecl IdRef>]
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
- defines NTs like Graph<d r>, Scope<d r>, Decl<d r>, Ref<d r> etc
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
- do not overload `d` or `r` as the name of lhs and type of something
  on rhs as was done in mk_decl and is still done in mk_ref

- rename decl to dcl


- in Resolution - replace .name with .obj.name
  replace .str_id with .obj.str_id
  but after making some more tests



 -}
