grammar lmlangmap;

imports scopegraph as sg;

global file_output::String = "scope_graph_lmlangmap.svg";

parser parse :: Program_c {
    lmlangmap;
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
  scope_graph = new(r.syn_graph);

  local attribute print_failure :: IOToken;
  print_failure = printT(sg:string_errors(scope_graph.sg:errors), ioin);

  local attribute print_resolution_paths :: IOToken;
  print_resolution_paths = systemT("echo '" ++ 
    sg:graphviz_draw_graph(r.syn_graph, (contains("--show-resolutions", largs)), (contains("--show-children", largs))) ++ 
    "' | dot -Tsvg > " ++ file_output, printT(if (contains("--graph-print", largs)) then "Graph print:\n" ++ sg:graphviz_draw_graph(scope_graph, true, true) ++ "\n" else "", ioin)).io;

{-
  local res::IO<Integer> = do {
    if length(largs) < 1 then do {
      print ("Ref: java -jar ***.jar <file name> <options>\n");
      return 1;
    }
    else do {


    if length(scope_graph.sg:errors) > 0
    then 
      do { 
        print ("Errors:\n" ++ string_errors(scope_graph.sg:errors));
        return 1;
      }
    else
      do {
       print ("Hello!\n");
       return 1;
      } ;
    } ;
-}
  
  return if length(scope_graph.sg:errors) <= 0 && result.parseSuccess then 
      ioval(print_resolution_paths, 0) 
    else 
      ioval(printT(sg:string_errors(scope_graph.sg:errors), print_resolution_paths), -1);
}
