grammar scopegraph;

function main
IO<Integer> ::= largs::[String]
{  
  return do { 
    print("Printing...\n"); return 0; 
  };
}