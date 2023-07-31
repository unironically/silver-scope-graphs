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
    --let regex :: Regex = star (concatenate (single (mod_lab), single (var_lab)));
    let regex :: Regex = star (alternate (single (var_lab), single (var_lab)));
    --let nfa :: NFA = regex.nfa;
    let dfa :: DFA = mk_dfa (regex.nfa);

    if (dfa.accepts ([]))
      then print ("DFA Accepts 1!\n")
      else print ("DFA Rejects 1!\n");

    print ("--\n");

    if (dfa.accepts ([mod_lab]))
      then print ("DFA Accepts 2!\n")
      else print ("DFA Rejects 2!\n");

    print ("--\n");

    if (dfa.accepts ([mod_lab, mod_lab]))
      then print ("DFA Accepts 3!\n")
      else print ("DFA Rejects 3!\n");

    print ("--\n");

    if (dfa.accepts ([mod_lab, var_lab]))
      then print ("DFA Accepts 4!\n")
      else print ("DFA Rejects 4!\n");
    
    print ("--\n");

    if (dfa.accepts ([var_lab]))
      then print ("DFA Accepts 5!\n")
      else print ("DFA Rejects 5!\n");

    print ("--\n");

    print ("MOD and LEX: " ++ toString (label_comp (mod_lab, lex_lab)) ++ "\n");
    print ("LEX and REC: " ++ toString (label_comp (lex_lab, rec_lab)) ++ "\n");
    print ("IMP and EXT: " ++ toString (label_comp (imp_lab, ext_lab)) ++ "\n");

    return 0;

  };


}