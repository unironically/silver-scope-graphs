grammar scope_tree_generic:driver;

imports scope_tree_generic:ast;

function main
IO<Integer> ::= largs::[String]
{


  return do {
    
    print ("Test!\n");

    let regex :: Regex = regex (star (single (lex_lab)));

    if accepts (regex.final_nfa, [])
      then print ("Accepts!\n")
      else print ("Rejects!\n");

    return 0;

  };


}