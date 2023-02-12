grammar test;

function main
IO<Integer> ::= largs::[String]
{  
  local ex1::X = 
    root(y_produce("a"), y_produce("b"));

  return do { print("Printing...\n" ++ ex1.printed); return 0; };
}