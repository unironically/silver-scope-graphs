grammar lmlangmap;

synthesized attribute parent<a>::Maybe<Scope<a>>;
synthesized attribute declarations<a>::[(String, a)];
synthesized attribute references::[String];

nonterminal Scope<a> with parent<a>, declarations<a>, references;

abstract production cons_scope
top::Scope<a> ::= par::Maybe<Scope<a>> decls::[(String, a)] refs::[String]
{
  top.parent = par;
  top.declarations = decls;
  top.references = refs;
}
