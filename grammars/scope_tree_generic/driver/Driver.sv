grammar scope_tree_generic:driver;

imports scope_tree_generic:ast;
imports scope_tree_generic:lmr;

function main
IO<Integer> ::= largs::[String]
{


  return do {
    
    print ("Test!\n");

    --let regex :: Regex = star (single (mod_lab));
    --let regex :: Regex = concatenate (single (mod_lab), single (mod_lab));
    let regex :: Regex = star (concatenate (single (mod_lab), single (var_lab)));

    if (regex.nfa.accepts ([]))
      then print ("Accepts 1!\n")
      else print ("Rejects 1!\n");

    if (regex.nfa.accepts ([mod_lab]))
      then print ("Accepts 2!\n")
      else print ("Rejects 2!\n");

    if (regex.nfa.accepts ([mod_lab, mod_lab]))
      then print ("Accepts 3!\n")
      else print ("Rejects 3!\n");

    if (regex.nfa.accepts ([mod_lab, var_lab]))
      then print ("Accepts 4!\n")
      else print ("Rejects 4!\n");


    if (regex.nfa.accepts ([var_lab]))
      then print ("Accepts 5!\n")
      else print ("Rejects 5!\n");

    return 0;

  };


}