grammar tester;

imports silver:testing ;
imports sc;

mainTestSuite core_tests ;

equalityTest ( 1 + 10, 4 + 7, Integer, core_tests ) ;
equalityTest ( 31 + 10, 34 + 7 , Integer, core_tests ) ;

{- Example 1
   ---
   def a_1 = ... b_5 ...
   def b_2 = a_3 ... a_4
-}
global e1 :: Scope = 
    root_scope (
      scope_tr ( dcl_cons (dcl_tr ("a",1),
                 dcl_cons (dcl_tr ("b",2), dcl_nil())),

                 ref_cons (ref_tr ("a",3),
                 ref_cons (ref_tr ("a",4),
                 ref_cons (ref_tr ("b",5), ref_nil()))),

                 ref_nil() ) );

equalityTest ( 
  resolve (("a",3), e1), [("a",1)], [(String,Integer)], core_tests);
equalityTest ( 
  resolve (("a",4), e1), [("a",1)], [(String,Integer)], core_tests);
equalityTest ( 
  resolve (("b",5), e1), [("b",2)], [(String,Integer)], core_tests);


{- Example 2
   ---
   def a_1 = ...
   def a_2 = ...
   def b_3 = a_4
-}
global e2 :: Scope = 
    root_scope (
      scope_tr ( dcl_cons (dcl_tr ("a",1),
                 dcl_cons (dcl_tr ("a",2),
                 dcl_cons (dcl_tr ("b",3), dcl_nil()))),

                 ref_cons (ref_tr ("a",4), ref_nil()),

                 ref_nil() ) );

equalityTest ( 
  resolve (("a",4), e2), [("a",1), ("a",2)], [(String,Integer)], core_tests);


{- Example 3
   ---
   module A_2 { def x_3 = ... }

   import A_5;
   def b_1 = x_4
-}
global e3 :: Scope = 
    root_scope (
      scope_tr ( dcl_cons (dcl_tr ("b",1),
                 dcl_cons (dcl_scope_tr ("A",2, 
                     scope_tr ( dcl_cons (dcl_tr ("x",3), dcl_nil()),
                                ref_nil(),  ref_nil()
                       )
                     ), 
                 dcl_nil())),

                 ref_cons (ref_tr ("x",4), ref_nil()),

                 ref_cons (imp_tr ("A",5), ref_nil())
               )
      ) ;

equalityTest (
  resolve (("x",4), e3), [("x",3)], [(String,Integer)], core_tests);



{- Example 4
   ---
   module A_1 {
     module A_2 { def a_3 = ... }
   }
   import A_4
   def b_5 = a_6
-}

  -- Root
global e4 :: Scope = root_scope (
    scope_tr ( dcl_cons (e4_a1, 
               dcl_cons (dcl_tr ("b",5),
               dcl_nil())),

               ref_cons (ref_tr ("a",6), ref_nil()),
               ref_cons (imp_tr ("A",4), ref_nil()) ) );

  -- A1
global e4_a1 :: Dcl = dcl_scope_tr ("A",1, 
    scope_tr ( dcl_cons (e4_a2, dcl_nil()), 
                                 ref_nil(), ref_nil() )
    );

  -- A2
global e4_a2 :: Dcl = dcl_scope_tr ("A",2, 
    scope_tr ( dcl_cons (dcl_tr ("a",3), dcl_nil()),
                                 ref_nil(), ref_nil() )
   );

equalityTest (
  resolve (("a",6), e4), [], [(String,Integer)], core_tests);
equalityTest (
  resolve (("A",4), e4), [("A",1)], [(String,Integer)], core_tests);



{- Example 5
   ---
   module A_1 {
     module B_2 { def a_3 = d_9 }
     def d_8 = ...
   }
   import A_4
   import B_5
   def c_6 = a_7
 -}

-- Root
global e5 :: Scope = root_scope (
    scope_tr ( dcl_cons (e5_a1, 
               dcl_cons (dcl_tr ("c",6),
               dcl_nil())),

               ref_cons (ref_tr ("a",7), ref_nil()),
               --ref_nil(),

               ref_cons (imp_tr ("A",4), 
               ref_cons (imp_tr ("B",5), 
               ref_nil()))
    ) );

-- A1
global e5_a1 :: Dcl = dcl_scope_tr ("A",1, 
    scope_tr ( dcl_cons (e5_b2, 
               dcl_cons (dcl_tr("d",8), dcl_nil())), 
               ref_nil(), ref_nil() )
    );

-- A2
global e5_b2 :: Dcl = dcl_scope_tr ("B",2, 
    scope_tr ( dcl_cons (dcl_tr ("a",3), dcl_nil()),
               ref_cons (ref_tr("d",9),ref_nil()), 
               ref_nil() )
   );

equalityTest (
  resolve (("a",7), e5), [("a",3)], [(String,Integer)], core_tests);
equalityTest (
  resolve (("d",9), e5), [("d",8)], [(String,Integer)], core_tests);

equalityTest (
  resolve (("A",4), e5), [("A",1)], [(String,Integer)], core_tests);
equalityTest (
  resolve (("B",5), e5), [("B",2)], [(String,Integer)], core_tests);


{- Example 6
   ---
   module A_1 {
     module A_2 { def a_3 = ... }
   }
   import A_4
   import A_5
   def b_6 = a_7
-}

-- Root 
global e6 :: Scope = root_scope (
    scope_tr ( dcl_cons (e6_a1, 
               dcl_cons (dcl_tr ("b",6),
               dcl_nil())),

               ref_cons (ref_tr ("a",7), ref_nil()),

               ref_cons (imp_tr ("A",4), 
               ref_cons (imp_tr ("A",5), 
               ref_nil()))
    ) );

-- A1
global e6_a1 :: Dcl = dcl_scope_tr ("A",1, 
    scope_tr ( dcl_cons (e6_a2, dcl_nil()), 
                                 ref_nil(), ref_nil() )
    );

-- A2
global e6_a2 :: Dcl = dcl_scope_tr ("A",2, 
    scope_tr ( dcl_cons (dcl_tr ("a",3), dcl_nil()),
                                 ref_nil(), ref_nil() )
   );


equalityTest (
  resolve (("a",7), e6), [], [(String,Integer)], core_tests);
equalityTest (
  resolve (("A",4), e6), [("A",1)], [(String,Integer)], core_tests);
equalityTest (
  resolve (("A",5), e6), [("A",1)], [(String,Integer)], core_tests);






{- Example 4
   ---
   module A { def x = ... }
   module B { def x = ... }
   def x = _
   import A;
   import B;
   def _ = x   - x has either 1 or 3 reachable declarations,
                 depending the language.
                 Do we have different scope graphs for each interpretation?
                 Or different orderings on paths?
-}







function getNameIndexRef
(String, Integer) ::= r::Decorated Ref
{
  return (r.name, r.index); 
}

function getNameIndexDcl
(String, Integer) ::= d::Decorated Dcl
{
 return (d.name, d.index); 
}

function resolve
[(String, Integer)] ::= r::(String, Integer) s::Scope
{
  return sort (map (getNameIndexDcl, resolutions (r, s)));
}


function resolutions
[Decorated Dcl] ::= r::(String, Integer) s::Scope
{
  return case r of
    | (name, index) ->
       case filter (
              (\r::Decorated Ref -> r.name == name && r.index == index), 
              s.all_refs) of
         | [] -> []
         | [r] -> r.visible
         | _ -> error ("reference appeared multiple times in all_refs")
         end
    end;
}
