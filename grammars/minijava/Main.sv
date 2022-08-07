grammar minijava;

global file_output::String = "scope_graph_minijava.svg";


parser parse :: Program_c {
    minijava;
}

function main
IOVal<Integer> ::= largs::[String] ioin::IOToken
{
  local attribute args::String;
  args = head(largs);

  local attribute result :: ParseResult<Program_c>;
  result = parse(args, "<<args>>");

  local attribute r_cst::Program_c;
  r_cst = result.parseTree;

  local attribute r::Program = r_cst.ast;

  return if result.parseSuccess then ioval(printT("Success", ioin), 0) else ioval(printT("Failure", ioin), -1);
}
