grammar scopegraph;

----------------
-- Errors:

nonterminal Error<a> with message, next<a>;

synthesized attribute message::String;
synthesized attribute next<a>::Error<a>;

@{-
 - The error constructed when multiple declaration nodes are found when resolving a reference.
 -
 - @param usage The reference node for which multiple declarations are found.
 - @param next The next error in the linked list.
-}
abstract production multiple_declarations_found
top::Error<a> ::= usage::Usage<a> next::Error<a>
{
  top.message = "Multiple declarations found that match reference for: " ++ usage.identifier ++ 
    " at line: " ++ toString(usage.line) ++ " col: " ++ toString(usage.column);
  top.next = next;
}

@{-
 - The error constructed when no declaration nodes are found when resolving a reference.
 -
 - @param usage The reference node for which no declarations are found.
 - @param next The next error in the linked list.
-}
abstract production no_declaration_found
top::Error<a> ::= usage::Usage<a> next::Error<a>
{
  top.message = "No declaration found that matches reference for: " ++ usage.identifier ++ 
    " at line: " ++ toString(usage.line) ++ " col: " ++ toString(usage.column);
  top.next = next;
}

@{-
 - The error constructed when a declaration node has no corresponding references in a scope graph. 
 -
 - @param declaration The declaration node that no references are found for. 
 - @param next The next error in the linked list.
-}
abstract production declaration_unused
top::Error<a> ::= declaration::Declaration<a> next::Error<a>
{
  top.message = "Declaration never used: " ++ declaration.identifier ++ 
    " at line: " ++ toString(declaration.line) ++ ", col: " ++ toString(declaration.column);
  top.next = next;
}