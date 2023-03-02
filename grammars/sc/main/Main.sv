grammar main;

{- This is a simple `main` grammar to run simple tests.

   The better testing work is in the `testing` grammar.
 -}

imports silver:langutil;
imports silver:langutil:pp;

imports testing;
imports scope_tree:ast;

function main
IO<Integer> ::= largs::[String] 
{
  return do {
     display(e5, "e5");
     return 0;
  };
}


function display
IO<Unit> ::= s::ScopeGraph name::String 
{
  return do {
    print ("\n------------------------------------------------------------\n" ++ 
           "Example: " ++ name ++ "\n");
    print (show (60, s.pp));
    print ("\n");
--    print (report (s.all_refs));
    return ();
  };
}

