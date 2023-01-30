grammar sc;


function main
IO<Integer> ::= largs::[String] 
{

  -- Root
  local s1 :: Scope = scope_tr ( dcl_cons (a1, dcl_cons (b5, dcl_nil())),
                                 ref_cons (a6, ref_nil()),
                                 ref_cons (a4, ref_nil()) );
  local a4 :: Ref = imp_tr ("A");
  local b5 :: Dcl = dcl_tr ("b");
  local a6 :: Ref = ref_tr ("a");


  -- A1
  local a1 :: Dcl = dcl_scope_tr ("A", s2);
  local s2 :: Scope = scope_tr ( dcl_cons (a2, dcl_nil()), ref_nil(), ref_nil() );

  -- A2
  local a2 :: Dcl = dcl_scope_tr ("A", s3);
  local s3 :: Scope = scope_tr ( dcl_cons (a3, dcl_nil()), ref_nil(), ref_nil() );
  local a3 :: Dcl = dcl_tr ("a");



  return do {
     print("Success!\n"); 
     return 0;
  };
}
