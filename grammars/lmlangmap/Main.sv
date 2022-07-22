grammar lmlangmap;

global file_output::String = "scope_graph.svg";

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

  local attribute scope_graph :: Graph_type;
  scope_graph = new(r.syn_graph);

  --local attribute print_success :: IOToken;
  --print_success = ;

  local attribute print_failure :: IOToken;
  print_failure = printT(string_errors(scope_graph.errors), ioin);

  local attribute print_resolution_paths :: IOToken;
  print_resolution_paths = systemT("echo '" ++ 
    graphviz_draw_graph(scope_graph, (contains("--show-resolutions", largs)), (contains("--show-children", largs))) ++ 
    "' | dot -Tsvg > " ++ file_output, printT(if (contains("--graph-print", largs)) then "Graph print:\n" ++ graphviz_draw_graph(scope_graph, true, true) ++ "\n" else "", ioin)).io;

{-
  local res::IO<Integer> = do {
    if length(largs) < 1 then do {
      print ("Usage: java -jar ***.jar <file name> <options>\n");
      return 1;
    }
    else do {


    if length(r.errors) > 0
    then 
      do { 
        print ("Errors:\n" ++ string_errors(r.errors));
        return 1;
      }
    else
      do {
       print ("Hello!\n");
       return 1;
      } ;
    } ;
-}
  --return 
      --ioval(if length(r.errors) <= 0 then print_resolution_paths else print_failure, 0);
      return if length(scope_graph.errors) <= 0 then ioval(print_resolution_paths, 0) else ioval(print_resolution_paths, -1);
     -- evalIO (res, ioin) ;
}
