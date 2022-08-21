grammar lmlangtree;

imports scopetree as sg;

global file_output::String = "scope_graph_lmlangmap.svg";

parser parse :: Program_c {
    lmlangtree;
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

  local attribute all_scopes::[sg:Scope<IdDcl IdRef>] = r.all_scopes;

  local attribute printed::String = foldl(
    (\acc::String scope::sg:Scope<IdDcl IdRef> -> acc ++ " [" ++ foldl((\acc::String ref::sg:Ref<IdDcl IdRef> -> acc ++ " " ++ ref.sg:res_str), "", scope.sg:refs) ++ "]\n"), 
    "", 
    all_scopes);

  return if result.parseSuccess then 
      ioval(printT("Success: " ++ r.pp ++ "\n" ++ printed ++ "\n", ioin), 0) 
    else 
      ioval(printT("Error\n", ioin), -1);
}
