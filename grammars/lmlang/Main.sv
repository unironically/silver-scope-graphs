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

  local attribute top_scope::Scope = r.final_scope;
  local attribute scope_print::String = top_scope.graphpp;

  local attribute print_success :: IOToken;
  print_success = printT("Success!" ++ "\n" ++ r.pp ++ "\n" ++ scope_print ++ "\n", ioin);

  local attribute print_failure :: IOToken;
  print_failure = printT("Failure!", ioin);

  return ioval(if result.parseSuccess then print_success else print_failure, 0);

}
