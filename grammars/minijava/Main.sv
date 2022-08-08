grammar minijava;

global file_output_name::String = "scope_graph_minijava.svg";

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

  local attribute scope_graph :: sg:Graph<IdDcl IdRef>;
  scope_graph = new(r.scope_graph);

  local attribute print_resolution_paths :: IOToken;
  print_resolution_paths = systemT("echo '" ++ 
    sg:graphviz_draw_graph(scope_graph) ++ 
    "' | dot -Tsvg > " ++ file_output_name, ioin).io;

  return if result.parseSuccess then ioval(printT("Success!", print_resolution_paths), 0) else ioval(printT("Failure", ioin), -1);
}
