grammar lmlang_basic;

imports lmlang as lm;

parser parse :: lm:Program_c {
    lmlang;
}

function main
IO<Integer> ::= largs::[String]
{
  local attribute args::String;
  args = head(largs);

  local attribute result :: ParseResult<lm:Program_c>;
  result = parse(args, "<<args>>");

  local attribute r_cst::lm:Program_c;
  r_cst = result.parseTree;

  local attribute r::lm:Program = r_cst.lm:ast;

  return if result.parseSuccess
    then do {print("Success!\n" ++ r.lm:pp ++ "\n" ++ r.str ++ "\n"); return 0;}
    else do {print("Something went wrong!\n"); return -1;};
}
