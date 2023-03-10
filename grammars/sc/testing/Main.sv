grammar testing;

imports silver:testing ;
imports scope_tree:ast;

-- The Visser algorithm. This works for all tests.
imports scope_tree:visser;

-- An attempt at the scopes_path approach in a functional style.
-- Some type errors need resolving here.
-- imports scope_tree:visser_scopes_path;

-- The first attempt at a RAG style. It works if one comments out 
-- the e5 and e6 tests.
-- imports scope_tree:rag_scopes_path;

mainTestSuite core_tests ;

equalityTest ( 1 + 10, 4 + 7, Integer, core_tests ) ;
equalityTest ( 31 + 10, 34 + 7 , Integer, core_tests ) ;

{- Example 1
   ---
   def a_1 = ... b_5 ...
   def b_2 = a_3 ... a_4
-}
global e1 :: ScopeGraph = 
    root (
      scope_tr ( 11,
                 dcl_cons (dcl_tr ("a",1),
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
global e2 :: ScopeGraph = 
    root (
      scope_tr ( 11,
                 dcl_cons (dcl_tr ("a",1),
                 dcl_cons (dcl_tr ("a",2),
                 dcl_cons (dcl_tr ("b",3), dcl_nil()))),

                 ref_cons (ref_tr ("a",4), ref_nil()),

                 ref_nil() ) );

equalityTest ( 
  resolve (("a",4), e2), [("a",1), ("a",2)], [(String,Integer)], core_tests);


{- Example 3
   ---
   module A_2 {_12 def x_3 = ... }

   import A_5;
   def b_1 = x_4
-}
global e3 :: ScopeGraph = 
    root (
      scope_tr ( 11,
                 dcl_cons (dcl_tr ("b",1),
                 dcl_cons (dcl_scope_tr ("A",2, 
                     scope_tr ( 12, 
                                dcl_cons (dcl_tr ("x",3), dcl_nil()),
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
   module A_1 {_12
     module A_2 {_13 def a_3 = ... }
   }
   import A_4
   def b_5 = a_6
-}

  -- ScopeGraph
global e4 :: ScopeGraph = root (
    scope_tr ( 11,
               dcl_cons (e4_a1, 
               dcl_cons (dcl_tr ("b",5),
               dcl_nil())),

               ref_cons (ref_tr ("a",6), ref_nil()),
               ref_cons (imp_tr ("A",4), ref_nil()) ) );

  -- A1
global e4_a1 :: Dcl = dcl_scope_tr ("A",1, 
    scope_tr (12, dcl_cons (e4_a2, dcl_nil()), 
                                 ref_nil(), ref_nil() )
    );

  -- A2
global e4_a2 :: Dcl = dcl_scope_tr ("A",2, 
    scope_tr (13, dcl_cons (dcl_tr ("a",3), dcl_nil()),
                                 ref_nil(), ref_nil() )
   );

equalityTest (
  resolve (("a",6), e4), [], [(String,Integer)], core_tests);
equalityTest (
  resolve (("A",4), e4), [("A",1)], [(String,Integer)], core_tests);



{- Example 5
   ---
   module A_1 {_12
     module B_2 {_13 def a_3 = d_9 }
     def d_8 = ...
   }
   import A_4
   import B_5
   def c_6 = a_7
 -}

-- ScopeGraph
global e5 :: ScopeGraph = root (
    scope_tr ( 11,
               dcl_cons (e5_a1, 
               dcl_cons (dcl_tr ("c",6),
               dcl_nil())),

               ref_cons (ref_tr ("a",7), ref_nil()),
               --ref_nil(),

               ref_cons (imp_tr ("A",4), 
               ref_cons (imp_tr ("B",5), 
               ref_nil()))
    ) );

-- A_1
global e5_a1 :: Dcl = dcl_scope_tr ("A",1, 
    scope_tr ( 12,
               dcl_cons (e5_b2, 
               dcl_cons (dcl_tr("d",8), dcl_nil())), 
               ref_nil(), ref_nil() )
    );

-- B_2
global e5_b2 :: Dcl = dcl_scope_tr ("B",2, 
    scope_tr ( 13,
               dcl_cons (dcl_tr ("a",3), dcl_nil()),
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
   module A_1 {_12
     module A_2 {_13 def a_3 = ... }
   }
   import A_4
   import A_5
   def b_6 = a_7
-}

-- ScopeGraph 
global e6 :: ScopeGraph = root (
    scope_tr ( 11,
               dcl_cons (e6_a1, 
               dcl_cons (dcl_tr ("b",6),
               dcl_nil())),

               ref_cons (ref_tr ("a",7), ref_nil()),

               ref_cons (imp_tr ("A",4), 
               ref_cons (imp_tr ("A",5), 
               ref_nil()))
    ) );

-- A1
global e6_a1 :: Dcl = dcl_scope_tr ("A",1, 
    scope_tr (12, dcl_cons (e6_a2, dcl_nil()), 
                                 ref_nil(), ref_nil() )
    );

-- A2
global e6_a2 :: Dcl = dcl_scope_tr ("A",2, 
    scope_tr (13, dcl_cons (dcl_tr ("a",3), dcl_nil()),
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





