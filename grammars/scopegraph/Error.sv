grammar scopegraph;

----------------
-- Errors:

nonterminal Error<d r> with message, all_messages;

synthesized attribute message::String;
synthesized attribute all_messages::String;

@{-
 - The error constructed when multiple declaration nodes are found when resolving a reference.
 -
 - @param usage The reference node for which multiple declarations are found.
-}
abstract production multiple_declarations_found
top::Error<d r> ::= usage::Decorated Usage<d r> resolved_to::[Decorated Declaration<d r>]
{
  top.message = "Multiple declarations found that match reference: " ++ usage.to_string ++ ":" ++
    foldl((\acc::String dcl::Decorated Declaration<d r> -> acc ++ "\n\t" ++ dcl.to_string), "", resolved_to);
}

@{-
 - The error constructed when no declaration nodes are found when resolving a reference.
 -
 - @param usage The reference node for which no declarations are found.
-}
abstract production no_declaration_found
top::Error<d r> ::= usage::Decorated Usage<d r>
{
  top.message = "No declaration found that matches reference for: " ++ usage.to_string;
}

@{-
 - The error constructed when a declaration node has no corresponding references in a scope graph. 
 -
 - @param declaration The declaration node that no references are found for. 
-}
abstract production declaration_unused
top::Error<d r> ::= declaration::Decorated Declaration<d r>
{
  top.message = "Declaration never used: " ++ declaration.to_string;
}

@{-
 - Concatenate string information from a list of errors.
 -
 - @param list The list of errors to output.
 - @return The string representing all errors found.
-}
function string_errors
String ::= list::[Decorated Error<d r>]
{
  return case list of 
  | h::t -> "ERROR: " ++ h.message ++ "\n" ++ string_errors(t)
  | [] -> ""
  end;
}
