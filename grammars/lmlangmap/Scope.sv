grammar lmlangmap;

type Declaration<a> = (String, a);
type Reference = String;

synthesized attribute parent<a>::Maybe<Scope<a>>;
synthesized attribute declarations<a>::[Declaration<a>];
synthesized attribute references::[Reference];

nonterminal Scope<a> with parent<a>, declarations<a>, references;

abstract production cons_scope
top::Scope<a> ::= par::Maybe<Scope<a>> decls::[Declaration<a>] refs::[Reference]
{
  top.parent = par;
  top.declarations = decls;
  top.references = refs;
}

@{--
 - Merges two lists of declarations such that the left-hand list shadows the right
 -
 - @param left The left-hand list of declarations, which shadows the right
 - @param right The shadowed right-hand list of declarations
-}
function merge_declarations_with_shadowing
[Declaration<a>] ::= left::[Declaration<a>] right::[Declaration<a>]
{
  return unionBy (\mem_r::Declaration<a> mem_l::Declaration<a> -> fst(mem_r) == fst(mem_l), 
      right , left);
}
