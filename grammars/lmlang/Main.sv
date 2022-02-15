grammar lmlang;

parser parse :: Program_c {
    lmlang;
}

function main
IOVal<Integer> ::= largs::[String] ioin::IOToken
{

  local attribute args::String;
  args = implode(" ", largs);

  local attribute result :: ParseResult<Program_c>;
  result = parse(args, "<<args>>");

  local attribute r_cst::Program_c;
  r_cst = result.parseTree;

  local attribute r::Program = r_cst.ast;
    
  local attribute print_success :: IOToken;
  print_success = printT("Success!" ++ "\n" ++ r.pp ++ "\n", ioin);

  local attribute print_failure :: IOToken;
  print_failure = printT("Failure!", ioin);

  return ioval(if result.parseSuccess then print_success else print_failure, 0);

}
