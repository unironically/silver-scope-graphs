grammar lmlangmap_test;

import silver:testing;
import scopegraph;
import lmlangmap;

mainTestSuite lmlangmap_testing;

function def_example1
Boolean ::= errors:[Decorated Error<a>]
{
  return case errors of 
    | multiple_declarations_found(_)::no_declaration_found(_)::[] -> true
    | _ -> false
    end;
}

equalityTest();