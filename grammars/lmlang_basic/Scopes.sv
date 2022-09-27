grammar lmlang_basic;

nonterminal Scope with par, decls;

synthesized attribute par::Maybe<Scope>;
synthesized attribute decls::[lm:IdDecl];

abstract production mk_scope
top::Scope ::= 
  par::Maybe<Scope>
  decls::[lm:IdDecl]
{
  top.par = par;
  top.decls = decls;
}