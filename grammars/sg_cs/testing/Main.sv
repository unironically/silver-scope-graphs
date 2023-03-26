grammar sg_cs:testing;

imports silver:testing ;
imports sg_cs;

imports scope_tree:ast as sg;
imports scope_tree:visser as res;


mainTestSuite core_tests ;

-- Tests for understanding the testing framework
equalityTest ( 1 + 10, 4 + 7, Integer, core_tests ) ;
equalityTest ( 31 + 10, 34 + 7 , Integer, core_tests ) ;


-- Testing the parser
global e1 :: String = "decls a_1  refs  a_2";

equalityTest (
  parse (e1 , "text" ).parseSuccess, true, Boolean, core_tests );


-- Testing simple resolutions
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
         | (r, d)::t -> (r.sg:id, d.sg:id) :: bind_ids(t)
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

  They should/could have
  - name : something that yeilds a string
  - index/identifier
  - location : a  where this is some sort of location information
           we'll see what functions we need on this

** Scope Graph AST
** ---------------
- defines NTs like Graph<d r>, Scope<d r>, Decl<d r>, Ref<d r> etc
- also productions for making the scope tree

- the interface to resolutions
  - collect all Ref and Dcl nodes at the top - raw data

- *** what reference attributes do we have that complete the "graph" ?
  - Refs have `resolutions` - list of visible Dcls
  - Dcls have 'uses` - list of all of its Refs (maybe add this)

  - Scopes? Associated scopes?



** To Do
** -----
- do not overload `d` or `r` as the name of lhs and type of something
  on rhs as was done in mk_decl and is still done in mk_ref

- rename decl to dcl


 -}
