grammar scope_tree_generic:driver;

imports scope_tree_generic:ast;

function main
IO<Integer> ::= largs::[String]
{


  return do {
    
    print ("Test!\n");

    let regex :: Regex = star (single (lex_lab));

    let start :: NFA_State = regex.nfa.start;
    print ("start: " ++ start.id ++ "\n");
    print ("accepting: " ++ implode (" ", map ((\s::NFA_State -> s.id), regex.nfa.accepting)) ++ "\n");
    print ("--------------\n");

    let one_lex :: [NFA_State] = start.next (lex_lab);
    print (foldl ((\str::String s::NFA_State -> str ++ s.id ++ "\n"), "", one_lex));

    return 0;

  };


}