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

  local attribute print_success :: IOToken;
  print_success = printT("Successful parse!\n" ++ 
    if (contains("--graph-print", largs)) then "Graph print:\n" ++ graphviz_draw_graph(r.syn_graph, true) ++ "\n" else "", ioin);

  local attribute print_failure :: IOToken;
  print_failure = printT("Parse failure!\n" ++ string_errors(r.errors), ioin);

  local attribute print_resolution_paths :: IOToken;
  print_resolution_paths = systemT("echo '" ++ 
    graphviz_draw_graph(r.syn_graph, (contains("--show-resolution", largs))) ++ 
    "' | dot -Tsvg > " ++ file_output, print_success).io;



 
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
  return 
      ioval(if length(r.errors) <= 0 then print_resolution_paths else print_failure, 0);
     -- evalIO (res, ioin) ;
}
