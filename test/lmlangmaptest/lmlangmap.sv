-- [1] A Theory of Name Resolution. Pierre Neron, Andrew P. Tolmach, Eelco Visser, Guido Wachsmuth. In Jan Vitek (editor), Programming Languages and Systems - 24th European Symposium on Programming, ESOP 2015, Held as Part of the European Joint Conferences on Theory and Practice of Software, ETAPS 2015, London, UK, April 11-18, 2015, Proceedings. 2015

grammar lmlangmaptest;

import silver:testing;
import scopegraph;
import lmlangmap;

mainTestSuite lmlangmaptesting;

function no_errors
Boolean ::= errors::[Decorated Error<a>]
{
  return case errors of 
    | [] -> true
    | _ -> false
  end;
}

function def_example1
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
  def_example1(parse_input_ast("def a = 0 def b = a + c def b = b + d def c = 0").errors),
  true,
  Boolean,
  lmlangmaptesting
);

----------------
-- Input program from Fig. 7 of [1]:

equalityTest(
  no_errors(parse_input_ast("def c = 4 module x { import y def a = b + c } module y { import z def b = 0 } module z { def b = 1 def c = b }").errors),
  true,
  Boolean
  ,lmlangmaptesting
);

----------------
-- Taking a plaintext program and parsing it for an AST:

function parse_input_ast
Program ::= input::String
{
    local attribute result :: ParseResult<Program_c>;
    result = parse(input, "<<args>>");
    local attribute r_cst::Program_c;
    r_cst = result.parseTree;
    return r_cst.ast;
}