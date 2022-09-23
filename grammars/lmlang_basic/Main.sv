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

  local attribute result :: ParseResult<lm:Program_c> = parse(args, "<<args>>");
  local attribute r::lm:Program = result.parseTree.lm:ast;

  return if result.parseSuccess
    then do {print("Success!\n" ++ r.lm:pp ++ "\n"); return 0;}
    else do {print("Something went wrong!\n" ++ foldl((append), "", r.lm:errors)); return -1;};
}