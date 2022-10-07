grammar lmlang_full_list;

nonterminal Type;

synthesized attribute decls::[Decorated lm:IdDecl] occurs on Type;

abstract production int_type
top::Type ::=
{
  top.decls = [];
}

abstract production bool_type
top::Type ::=
{
  top.decls = [];
}

abstract production module_type
top::Type ::= decls::[Decorated lm:IdDecl]
{
  top.decls = decls;
}