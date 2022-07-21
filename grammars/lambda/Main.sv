grammar lambda ;

imports silver:langutil only pp, ast;
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

 local attribute print_failure::IOToken
  = printT("parse failed.\n" ++ result.parseErrors ++ "\n", text.io);
 
 {- Display pp unless it is "turned on" by some aspect of the driver
  - production contributing the value 'true' to the collection
  - attribute displayPP.
  -}
 production attribute displayPrettyPrint :: Boolean with || ;
 displayPrettyPrint := false ;

 {- Display errors if it is "turned on" by some aspect of the driver
  - production contributing the value 'true' to the collection
  - attribute displayErrors.
  -}
 production attribute displayErrors :: Boolean with || ;
 displayErrors := true ;

 production attribute tasks::[Task] with ++ ;
 tasks :=
   [ printPPTask(filename, r_cst, r_ast)
   , writePPTask(filename, r_ast) 
   , printErrorsTask(filename, r_ast)
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
  then ioval( print_failure, 1 )
  else ioval( allTasks.tioOut, 0 ) ;
}

nonterminal Task with tioIn, tioOut ;
inherited attribute tioIn :: IOToken ;
synthesized attribute tioOut :: IOToken ;

abstract production printPPTask
t::Task ::= filename::String r_cst::Decorated Root_c  r_ast::Decorated Root
{ t.tioOut = printT("Pretty print of program in \"" ++ filename ++ "\":\n" ++
                    "On CST:\n" ++ show(80,r_cst.pp) ++ "\n\n" ++ 
                    "On AST:\n" ++ show(80,r_ast.pp) ++ "\n\n", t.tioIn) ;
}

abstract production writePPTask
t::Task ::= filename::String r_ast::Decorated Root
{ t.tioOut = writeFileT(filenamePP, show(80,r_ast.pp), t.tioIn) ;
  local filenamePP::String = substring(0, length(filename)-7, filename) ++ "_pp.lambda" ;
}
abstract production printErrorsTask
t::Task ::= filename::String r_ast::Decorated Root
{ t.tioOut = if r_ast.errors == []
             then printT ("No errors found.\n", t.tioIn)
             else printT ("Errors of program in \"" ++ filename ++ "\":\n" ++
                    implode ("\n", r_ast.errors) ++ "\n\n", 
                    t.tioIn )  ;
}
abstract production writeErrorsTask
t::Task ::= filename::String r_ast::Decorated Root
{ t.tioOut = writeFileT(filenameErrors,
                       implode ("\n", r_ast.errors) ++ "\n\n",
                       t.tioIn) ;
  local filenameErrors::String = substring(0, length(filename)-3, filename) ++ ".errors" ;
}

abstract production concatTasks
t::Task ::= ts::[Task]
{ t.tioOut = if null(ts) then t.tioIn else rest.tioOut ;

  local first::Task = head(ts) ;
  first.tioIn = t.tioIn ;

  local rest::Task = concatTasks( tail(ts) ) ;
  rest.tioIn = first.tioOut ;
}



