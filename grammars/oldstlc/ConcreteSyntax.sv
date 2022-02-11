grammar oldstlc;

synthesized attribute ast<a>::a;

nonterminal Term_c with ast<Term>;

concrete productions top::Term_c
| Lambda_t ids::Identifiers_c Dot_t t::Term_c
  { 
    top.ast = ids.ast(t.ast); 
  }

| t1::Term_c App_t t2::Term_c
  { 
    top.ast = app(t1.ast, t2.ast); 
  }

| id::ID_t
  { 
    top.ast = var(id.lexeme); 
  }

| LParen_t t::Term_c RParen_t
  { 
    top.ast = t.ast; 
  }

nonterminal Identifiers_c with ast<(Term ::= Term)>;

concrete productions top::Identifiers_c
| h::ID_t t::Identifiers_c
  { 
    top.ast = \ b::Term -> abs(h.lexeme, t.ast(b)); 
  }

| h::ID_t
  { 
    top.ast = abs(h.lexeme, _); 
  }


