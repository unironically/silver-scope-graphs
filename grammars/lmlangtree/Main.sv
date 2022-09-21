grammar lmlangtree;

imports scopetree as sg;

global svg_out_name::String = "scope_graph_lmlangtree.svg";

parser parse :: Program_c {
    lmlangtree;
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

  local attribute scope_graph::sg:Graph<IdDcl IdRef> = r.graph;

  local attribute graph_output :: IO<Integer> = 
    system("echo '" ++ sg:graphviz_draw_graph(scope_graph) ++  "' | dot -Tsvg > " ++ svg_out_name);

  return if result.parseSuccess 
    then do {print("Success!\n"); print(sg:graphviz_draw_graph(scope_graph) ++ "\n"); graph_output; return 0;}
    else do {print("Something went wrong!\n"); return -1;};
}
