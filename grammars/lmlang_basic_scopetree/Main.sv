grammar lmlang_basic_scopetree;

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

  local attribute bindings_string::String = foldl (
    (\acc::String pair::(lm:IdRef, Decorated lm:IdDecl) -> 
      acc ++ "- " ++ fst(pair).str ++ " -> " ++ snd(pair).str ++ "\n"),
    "",
    r.bindings
  );

  return if result.parseSuccess
    then do {print("Success!\n" ++ bindings_string ++ "\n"); return 0;}
    else do {print("Something went wrong during parsing!\n"); return -1;};
}
