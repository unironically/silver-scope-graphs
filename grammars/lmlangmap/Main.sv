grammar lmlangmap;

global file_output::String = "scope_graph.svg";

parser parse :: Program_c {
    lmlangmap;
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
  print_success = printT("Successful parse\n" ++ string_paths(r.paths) ++ 
    "Scope graph illustration: " ++ file_output ++ "\n", ioin);

  local attribute print_failure :: IOToken;
  print_failure = printT("Parse failure\n" ++ string_errors(r.errors) ++ "\n" ++ r.pp, ioin);

  local attribute print_resolution_paths :: IOToken;
  print_resolution_paths = systemT("echo '" ++ graphviz_draw_graph(r.syn_graph, true) ++ 
    "' | dot -Tsvg > " ++ file_output, print_success).io;

  return ioval(if length(r.errors) <= 0 then print_resolution_paths else print_failure, 0);
}