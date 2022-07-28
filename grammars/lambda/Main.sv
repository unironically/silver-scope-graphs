grammar lambda ;

imports silver:langutil only ast, pp, unparse;
imports silver:langutil:pp;

parser hostParse :: Root_c {
  lambda;
} 

function main 
IOVal<Integer> ::= largs::[String] io_in::IOToken
{
  return driver(largs, hostParse, io_in) ;
}

function driver
IOVal<Integer> ::= args::[String]
                   parse::(ParseResult<Root_c> ::= String String)
                   driverIO::IOToken
{
 production attribute filename::String = head(args) ;
 local attribute fileExists::IOVal<Boolean> = isFileT(filename, driverIO);
 local attribute text::IOVal<String> = readFileT(filename,fileExists.io);
 local attribute result::ParseResult<Root_c> = parse(text.iovalue, filename);
 local attribute r_cst::Root_c = result.parseTree ;
 production attribute r_ast::Root = r_cst.ast ;

 local attribute parse_failure::IOToken
  = printT("parse failed.\n" ++ result.parseErrors ++ "\n", text.io);
 
 production attribute tasks::[Task] with ++ ;
 tasks :=
   [ printPPTask(r_cst, r_ast)
   , printTypingTask(r_ast)
   , printScopeGraphTask(r_ast)
   , writeScopeGraphTask(filename, r_ast)
   , printErrorsTask ("Scope Graph errors:", r_ast.errors)
   , generateSVGTask(filename)
   ];

 local allTasks :: Task = concatTasks(tasks) ;
 allTasks.tioIn = text.io ;

 return
  if   null(args)
  then ioval (printT ("Command line arguments required, usage \"java -jar lambda.jar <<filename>>\"\n", driverIO), 1)
  else
  if   ! fileExists.iovalue
  then ioval (printT ("File \"" ++ filename ++ "\" not found.\n\n",
              fileExists.io ) , 1 )
  else
  if   ! result.parseSuccess 
  then ioval( parse_failure, 1 )
  else ioval( allTasks.tioOut, 0 ) ;
}


nonterminal Task with tioIn, tioOut ;
inherited attribute tioIn :: IOToken ;
synthesized attribute tioOut :: IOToken ;

abstract production printScopeGraphTask
t::Task ::= r_ast::Decorated Root
{ t.tioOut = printT("Scope Graph:\n" ++
     sg:graphviz_draw_graph(r_ast.scope_graph, true, true) ++ "\n\n", 
     t.tioIn) ;
}

abstract production writeScopeGraphTask
t::Task ::= filename::String r_ast::Decorated Root
{ t.tioOut = writeFileT (
     dot_filename,
     sg:graphviz_draw_graph(r_ast.scope_graph, true, true),
     t.tioIn) ;
  local dot_filename :: String = filename_base(filename) ++ ".dot";
}

abstract production generateSVGTask
t::Task ::= filename::String 
{ t.tioOut = systemT("dot -Tsvg " ++ dot_filename ++ " -o " ++ svg_filename, t.tioIn) . io ;
  local dot_filename :: String = filename_base(filename) ++ ".dot";
  local svg_filename :: String = filename_base(filename) ++ ".svg";
}

abstract production printPPTask
t::Task ::=r_cst::Decorated Root_c  r_ast::Decorated Root
{ t.tioOut = printT("Pretty print of program:\n" ++
                    "On CST:\n" ++ show(80,r_cst.pp) ++ "\n\n" ++ 
                    "On AST:\n" ++ show(80,r_ast.pp) ++ "\n\n", t.tioIn) ;
}

abstract production writePPTask
t::Task ::= filename::String r_ast::Decorated Root
{ t.tioOut = writeFileT(pp_filename, show(80,r_ast.pp), t.tioIn) ;
  local pp_filename::String = filename_base(filename) ++ ".pp" ;
}

abstract production printTypingTask
t::Task ::= r_ast::Decorated Root
{ t.tioOut = case r_ast.typing of
             | typed (typ) -> printT ("No errors found. Expression had type:\n  " ++
                  show(80, typ.pp) ++ "\n", t.tioIn)
             | type_errs (errs) -> printT ("Errors:\n" ++
                    implode ("\n", map ( (.msg), errs) ) ++ "\n\n", 
                    t.tioIn ) 
             end ;
}

abstract production printErrorsTask
t::Task ::= prompt::String errs :: [ Error ]
{ 
  local printPrompt :: IOToken = printT(prompt ++ "\n\n", t.tioIn);
  t.tioOut = 
    if null(errs) 
    then printT ("No errors found.\n\n", printPrompt)
    else printT ("Errors:\n" ++ implode ("\n", map ( (.msg), errs) ) ++ "\n\n",
                 printPrompt);
}


abstract production concatTasks
t::Task ::= ts::[Task]
{ t.tioOut = if null(ts) then t.tioIn else rest.tioOut ;

  local first::Task = head(ts) ;
  first.tioIn = t.tioIn ;

  local rest::Task = concatTasks( tail(ts) ) ;
  rest.tioIn = first.tioOut ;
}


function filename_base
String ::= filename::String
{
  return substring (0, lastIndexOf(".", filename), filename);
}



