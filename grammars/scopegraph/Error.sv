grammar scopegraph;

----------------
-- Errors:

nonterminal Error<a> with message, all_messages;

synthesized attribute message::String;
synthesized attribute all_messages::String;

@{-
 - The error constructed when multiple declaration nodes are found when resolving a reference.
 -
 - @param usage The reference node for which multiple declarations are found.
-}
abstract production multiple_declarations_found
top::Error<a> ::= usage::Usage<a>
{
  top.message = "Multiple declarations found that match reference for: " ++ usage.identifier ++ 
    " at line: " ++ toString(usage.line) ++ " col: " ++ toString(usage.column);
}

@{-
 - The error constructed when no declaration nodes are found when resolving a reference.
 -
 - @param usage The reference node for which no declarations are found.
-}
abstract production no_declaration_found
top::Error<a> ::= usage::Usage<a>
{
  top.message = "No declaration found that matches reference for: " ++ usage.identifier ++ 
    " at line: " ++ toString(usage.line) ++ " col: " ++ toString(usage.column);
}

@{-
 - The error constructed when a declaration node has no corresponding references in a scope graph. 
 -
 - @param declaration The declaration node that no references are found for. 
-}
abstract production declaration_unused
top::Error<a> ::= declaration::Declaration<a>
{
  top.message = "Declaration never used: " ++ declaration.identifier ++ 
    " at line: " ++ toString(declaration.line) ++ ", col: " ++ toString(declaration.column);
}

function string_errors
String ::= list::[Decorated Error<a>]
{
  return case list of 
  | h::t -> h.message ++ string_errors(t)
  | [] -> ""
  end;
}