grammar oldstlc;

parser parse :: Term_c {
    oldstlc;
}

function main
IOVal<Integer> ::= largs::[String] ioin::IOToken
{

  local attribute args::String;
  args = implode(" ", largs);

  local attribute result :: ParseResult<Term_c>;
  result = parse(args, "<<args>>");

  local attribute r_cst::Term_c;
  r_cst = result.parseTree;

  local attribute r::Term = r_cst.ast;
    
  local attribute print_success :: IOToken;
  print_success = printT("Success!" ++ "\n" ++ r.pp ++ "\n", ioin);

  local attribute print_failure :: IOToken;
  print_failure = printT("Failure!", ioin);

  return ioval(if result.parseSuccess then print_success else print_failure, 0);

}
