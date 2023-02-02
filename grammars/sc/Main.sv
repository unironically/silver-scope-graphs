grammar sc;


function main
IO<Integer> ::= largs::[String] 
{

  {- Example 1
   ---
   def a = ...
   def b = a
  -}
  local e1 :: Scope = 
    root_scope (
      scope_tr ( dcl_cons (dcl_tr ("a"),
                   dcl_cons (dcl_tr ("b"), dcl_nil())),

                 ref_cons (ref_tr ("a"), ref_nil()),

                 ref_nil() ) );

  {- Example 2
   ---
   def a = ...
   def a = ...
   def b = a
  -}
  local e2 :: Scope = 
    root_scope (
      scope_tr ( dcl_cons (dcl_tr ("a"),
                   dcl_cons (dcl_tr ("a"),
                     dcl_cons (dcl_tr ("b"), dcl_nil()))),

                 ref_cons (ref_tr ("a"), ref_nil()),

                 ref_nil() ) );



  {- Example 3
   ---
   module A { def x = ... }

   import A;
   def b = x
  -}
  local e3 :: Scope = 
    root_scope (
      scope_tr ( dcl_cons (dcl_tr ("b"),
                 dcl_cons (dcl_scope_tr ("A", 
                     scope_tr ( dcl_cons (dcl_tr ("x"), dcl_nil()),
                                ref_nil(),  ref_nil()
                       )
                     ), 
                 dcl_nil())),

                 ref_cons (ref_tr ("x"), ref_nil()),

                 ref_cons (imp_tr ("A"), ref_nil())
               )
      ) ;


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



  {- Example 5
   ---
   module A {
     module A { def a = ... }
   }
   import A
   def b = a
   -}

  -- Root
  local e5 :: Scope = root_scope (
    scope_tr ( dcl_cons (a1, 
               dcl_cons (dcl_tr ("b"),
               dcl_nil())),

               ref_cons (ref_tr ("a"), ref_nil()),
               ref_cons (imp_tr ("A"), ref_nil()) ) );

  -- A1
  local a1 :: Dcl = dcl_scope_tr ("A", 
    scope_tr ( dcl_cons (a2, dcl_nil()), 
                                 ref_nil(), ref_nil() )
    );

  -- A2
  local a2 :: Dcl = dcl_scope_tr ("A", 
    scope_tr ( dcl_cons (dcl_tr ("a"), dcl_nil()),
                                 ref_nil(), ref_nil() )
   );


  {- Example 6
   ---
   module A_1 {
     module B_1 { def a = ... }
   }
   import A_2
   import B_2
   def b = a
   -}

  -- Root
  local e6 :: Scope = root_scope (
    scope_tr ( dcl_cons (a1_6, 
               dcl_cons (dcl_tr ("b"),
               dcl_nil())),

               ref_cons (ref_tr ("a"), ref_nil()),

               ref_cons (imp_tr ("A"), 
               ref_cons (imp_tr ("B"), 
               ref_nil()))
    ) );

  -- A1
  local a1_6 :: Dcl = dcl_scope_tr ("A", 
    scope_tr ( dcl_cons (b2_6, dcl_nil()), 
               ref_nil(), ref_nil() )
    );

  -- A2
  local b2_6 :: Dcl = dcl_scope_tr ("B", 
    scope_tr ( dcl_cons (dcl_tr ("a"), dcl_nil()),
               ref_nil(), ref_nil() )
   );


  {- Example 7
   ---
   module A {
     module A { def a = ... }
   }
   import A
   import A
   def b = a
   -}

  -- Root 
  local e7 :: Scope = root_scope (
    scope_tr ( dcl_cons (a1_7, 
               dcl_cons (dcl_tr ("b"),
               dcl_nil())),

               ref_cons (ref_tr ("a"), ref_nil()),

               ref_cons (imp_tr ("A"), 
               ref_cons (imp_tr ("A"), 
               ref_nil()))
    ) );

  -- A1
  local a1_7 :: Dcl = dcl_scope_tr ("A", 
    scope_tr ( dcl_cons (a2_7, dcl_nil()), 
                                 ref_nil(), ref_nil() )
    );

  -- A2
  local a2_7 :: Dcl = dcl_scope_tr ("A", 
    scope_tr ( dcl_cons (dcl_tr ("a"), dcl_nil()),
                                 ref_nil(), ref_nil() )
   );



  return do {
     print ("Example 1 (expect a declared 1 time)\n");
     print (report (e1.all_refs));
     print ("Example 2 (expect a 2) \n");
     print (report (e2.all_refs));
     print ("Example 3 (expect A 1, x 1\n");
     print (report (e3.all_refs));

     print ("Example 5 (expect A 1, a 0)\n");
     print (report (e5.all_refs));
     print ("Example 6 (expect A 1, A 1, a 1)\n");
     --print (report (e6.all_refs));
     print ("Example 7 (expect A 1, A 1, a 1)\n");
     print (report (e7.all_refs));
     return 0;
  };
}
