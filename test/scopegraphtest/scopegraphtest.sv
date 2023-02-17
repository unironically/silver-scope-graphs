grammar scopegraphtest;

imports scopegraph;

global fig5::String = 
  "decls a_1, b_2, b_5, c_8 refs a_3, c_4, b_6, d_7";
global fig6::String = 
  "decls n_8, f_1 refs f_9 { decls f_2 { decls n_3 refs n_4, n_5, n_7, f_6 }}";

@{-
 - Testing figure 5.
-}
equalityTest(
  sortBy (sort_ress, (parse_input_ast(fig5)).all_res),
  [
    ("a_3", ["a_1"]),
    ("b_6", ["b_2", "b_5"]),
    ("c_4", ["c_8"]),
    ("d_7", [])
  ],
  [(String, [String])],
  scopegraphtesting
);

@{-
 - Testing figure 6.
-}
equalityTest(
  sortBy (sort_ress, (parse_input_ast(fig6)).all_res),
  [
    ("f_6", ["f_2"]),
    ("f_9", ["f_1"]),
    ("n_4", ["n_3"]),
    ("n_5", ["n_3"]),
    ("n_7", ["n_3"])
  ],
  [(String, [String])],
  scopegraphtesting
);

{-====================-}

@{- -}
function parse_input_ast
Decorated Graph ::= input::String
{
    local attribute result :: ParseResult<Program_c>;
    result = parse(input, "<<args>>");
    local r_cst::Program_c = result.parseTree;
    local sg :: Decorated Graph = r_cst.graph_c;
    return sg;
}

function sort_ress
Boolean ::= p1::(String, [String]) p2::(String, [String])
{
  return fst(p1) < fst(p2);
}