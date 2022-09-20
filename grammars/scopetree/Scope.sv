grammar scopetree;

nonterminal Scope<d r> with id, str, parent<d r>, children<d r>;

synthesized attribute id::Integer;
synthesized attribute str::String;
synthesized attribute parent<d r>::Maybe<Decorated Scope<d r>>;
synthesized attribute children<d r>::[Scope<d r>];

synthesized attribute name::String;
synthesized attribute line::Integer;
synthesized attribute column::Integer;

--------------------
-- Scope nodes

abstract production mk_scope
top::Scope<d r> ::= 
  parent::Maybe<Decorated Scope<d r>>
  children::[Decorated Scope<d r>]
{
  top.id = genInt();
  top.parent = parent;
  top.children = children;
  top.str = toString(top.id);
}