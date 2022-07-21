grammar lambda ;

nonterminal Root_c with pp,ast<Root>;

-- Expression nonterminal, in order from lowest to highest precedence.
nonterminal Expr_Bnd_c with pp, ast<Expr>;
nonterminal Expr_Add_c with pp, ast<Expr>;
nonterminal Expr_Mul_c with pp, ast<Expr>;
nonterminal Expr_App_c with pp, ast<Expr>;
nonterminal Expr_Prm_c with pp, ast<Expr>;

-- Type, either functional or primitive types.
nonterminal Type_Arrow_c with pp, ast<Type>;
nonterminal Type_Prim_c with pp, ast<Type>;


-- Root
concrete productions r::Root_c
 | e::Expr_Bnd_c
   { r.pp = e.pp;
     r.ast = root(e.ast); }


-- Binding Expressions
concrete productions e::Expr_Bnd_c
 | 'let' ic::Id_t ':' ty::Type_Arrow_c '=' e1::Expr_Bnd_c 'in' e2::Expr_Bnd_c
   { e.pp = pp"let ${text(ic.lexeme)} : ${ty.pp} = ${e1.pp} in ${e2.pp}";
     e.ast = expr_let(ic.lexeme, ty.ast, e1.ast, e2.ast); }

 | 'lambda' i::Id_t ':' ty::Type_Arrow_c '.' e1::Expr_Bnd_c
   { e.pp = pp"lambda ${text(i.lexeme)} : ${ty.pp} . ${e1.pp}";
     e.ast = expr_lambda(i.lexeme, ty.ast, e1.ast); }

 | ea::Expr_Add_c 
   { e.pp = ea.pp;
     e.ast = ea.ast; }


-- Additive expressions
concrete productions e::Expr_Add_c
 | e1::Expr_Add_c '+' t::Expr_Mul_c
   { e.pp = pp"${e1.pp} + ${t.pp}";
     e.ast = expr_add(e1.ast, t.ast); }

 | e1::Expr_Add_c '-' t::Expr_Mul_c
   { e.pp = pp"${e1.pp} - ${t.pp}";
     e.ast = expr_sub(e1.ast, t.ast); }

 | t::Expr_Mul_c
   { e.pp = t.pp;
     e.ast = t.ast; }


-- Multiplicative Expressions
concrete productions t::Expr_Mul_c
 | t1::Expr_Mul_c '*' f::Expr_App_c 
   { t.pp = pp"${t1.pp} * ${f.pp}";
     t.ast = term_mul(t1.ast, f.ast); }

 | t1::Expr_Mul_c '/' f::Expr_App_c 
   { t.pp = pp"${t1.pp} / ${f.pp}";
     t.ast = term_div(t1.ast, f.ast); }

 | f::Expr_App_c
   { t.pp = f.pp;
     t.ast = f.ast; }


-- Function application expressions
concrete productions e::Expr_App_c
 | e1::Expr_App_c e2::Expr_Prm_c 
   { e.pp = pp"${e1.pp} ${e2.pp}";
     e.ast = expr_app (e1.ast, e2.ast); }

 | e1::Expr_Prm_c
   { e.pp = e1.pp;
     e.ast = e1.ast; }


-- Primitive Expressions
concrete productions e::Expr_Prm_c
 | '(' inner::Expr_Bnd_c ')'
   { e.pp = pp"(${inner.pp})";
     e.ast = inner.ast; }

 | i::Id_t
   { e.pp = text(i.lexeme);
     e.ast = factor_id(i.lexeme); }

 | i::IntLit_t
   { e.pp = text(i.lexeme);
     e.ast = factor_int(i.lexeme); }

-- Types
concrete productions t::Type_Arrow_c
 | tp::Type_Prim_c '->' ta::Type_Arrow_c
   { t.pp = pp"${tp.pp} -> ${ta.pp}";
     t.ast = arrow (tp.ast, ta.ast); }

 | tp::Type_Prim_c
   { t.pp = tp.pp;
     t.ast = tp.ast; }

concrete productions t::Type_Prim_c
 | 'int'
   { t.pp = text("int");
     t.ast = int(); }

 | '(' ta::Type_Arrow_c ')'
   { t.pp = pp"(${ta.pp})";
     t.ast = ta.ast; }

