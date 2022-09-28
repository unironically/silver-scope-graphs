grammar lmlang;

parser parse :: Program_c {
    lmlang;
}

function main
IO<Integer> ::= largs::[String]
{
  local attribute args::String;
  args = head(largs);

  local attribute result :: ParseResult<Program_c>;
  result = parse(args, "<<args>>");

  local attribute r_cst::Program_c;
  r_cst = result.parseTree;

  local attribute r::Program = r_cst.ast;

  return if result.parseSuccess
    then do {print("Success!\n"); return 0;}
    else do {print("Something went wrong during parsing!\n"); return -1;};
}
