-- [1] A Theory of Name Resolution. Pierre Neron, Andrew P. Tolmach, Eelco Visser, Guido Wachsmuth. In Jan Vitek (editor), Programming Languages and Systems - 24th European Symposium on Programming, ESOP 2015, Held as Part of the European Joint Conferences on Theory and Practice of Software, ETAPS 2015, London, UK, April 11-18, 2015, Proceedings. 2015

grammar lmlangmaptest;

import silver:testing;
import scopegraph;
import lmlangmap;

mainTestSuite lmlangmaptesting;

@{-
 - Handles cases where no scope errors are found.
 -
 - @param errors The list of scope errors found when parsing a program.
-}
function no_errors
Boolean ::= errors::[Decorated Error<a>]
{
  return case errors of 
    | [] -> true
    | _ -> false
  end;
}

@{-
 - Handles cases where no declarations are found for a single usage.
 -
 - @param errors The list of scope errors found when parsing a program.
-}
function no_declarations_only
Boolean ::= errors::[Decorated Error<a>]
{
  return case errors of 
    | no_declaration_found(_)::[] -> true
    | _ -> false
    end;
}

@{-
 - Handles cases where multiple declarations are found for a single usage.
 -
 - @param errors The list of scope errors found when parsing a program.
-}
function multiple_declarations_only
Boolean ::= errors::[Decorated Error<a>]
{
  return case errors of 
    | multiple_declarations_found(_)::[] -> true
    | _ -> false
    end;
}

@{-
 - Handles cases where multiple declarations are found for a single usage, and no declarations are found for another usage.
 -
 - @param errors The list of scope errors found when parsing a program.
-}
function multiple_and_no_declarations
Boolean ::= errors::[Decorated Error<a>]
{
  return case errors of 
    | multiple_declarations_found(_)::no_declaration_found(_)::[] -> true
    | _ -> false
    end;
}

----------------
-- Input program from Fig. 5 of [1]:

equalityTest(
  multiple_and_no_declarations(parse_input_ast("def a = 0 def b = a + c def b = b + d def c = 0").errors),
  true,
  Boolean,
  lmlangmaptesting
);

equalityTest(
  multiple_declarations_only(parse_input_ast("def a = 0 def b = a + c def b = b + a def c = 0").errors),
  true,
  Boolean,
  lmlangmaptesting
);

----------------
-- Input program from Fig. 7 of [1]:

equalityTest(
  no_errors(parse_input_ast("def c = 4 module x { import y def a = b + c } module y { import z def b = 0 } module z { def b = 1 def c = b }").errors),
  true,
  Boolean,
  lmlangmaptesting
);

equalityTest(
  no_errors(parse_input_ast("def c = 4 module x { import y def a = x + c } module y { import z def b = 0 } module z { def b = 1 def c = b }").errors),
  false,
  Boolean,
  lmlangmaptesting
);

----------------
-- Input program 1 from Fig. 14 of [1]:

equalityTest(
  no_errors(parse_input_ast("def a = 0 def b = 1 def c = 2 let a = c b = a c = b in a + b + c").errors),
  true,
  Boolean,
  lmlangmaptesting
);

equalityTest(
  no_errors(parse_input_ast("def a = 0 def b = 1 def c = 2 letrec a = c b = a c = b in a + b + c").errors),
  true,
  Boolean,
  lmlangmaptesting
);

equalityTest(
  no_errors(parse_input_ast("def a = 0 def b = 1 def c = 2 letpar a = c b = a c = b in a + b + c").errors),
  true,
  Boolean,
  lmlangmaptesting
);

equalityTest(
  no_declarations_only(parse_input_ast("def a = 0 def b = 1 def c = 2 let a = x x = a c = b in a + b + c").errors),
  true,
  Boolean,
  lmlangmaptesting
);

----------------
-- Taking a plaintext program and parsing it for an AST:

@{-
 - Parses an input program and produces the abstract syntax tree for that program.
 -
 - @param input The input program to parse as a plaintext string.
-}
function parse_input_ast
Program ::= input::String
{
    local attribute result :: ParseResult<Program_c>;
    result = parse(input, "<<args>>");
    local attribute r_cst::Program_c;
    r_cst = result.parseTree;
    return r_cst.ast;
}