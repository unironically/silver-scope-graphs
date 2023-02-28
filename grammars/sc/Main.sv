grammar sc;

imports tester;

function main
IO<Integer> ::= largs::[String] 
{
  return do {
     display(e5, "e5");
     return 0;
  };
}


function display
IO<Unit> ::= s::Scope name::String 
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

