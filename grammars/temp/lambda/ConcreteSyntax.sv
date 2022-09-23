grammar lambda ;

nonterminal Root_c with pp, ast<Root>, location;

-- Expression nonterminal, in order from lowest to highest precedence.
nonterminal Expr_Bnd_c with pp, ast<Expr>, location;
nonterminal Expr_Add_c with pp, ast<Expr>, location;
nonterminal Expr_Mul_c with pp, ast<Expr>, location;
nonterminal Expr_App_c with pp, ast<Expr>, location;
nonterminal Expr_Prm_c with pp, ast<Expr>, location;

-- Type, either functional or primitive types.
nonterminal Type_Arrow_c with pp, ast<TypeExpr>, location;
nonterminal Type_Prim_c with pp, ast<TypeExpr>, location;


-- Root
concrete productions r::Root_c
 | e::Expr_Bnd_c
   { r.pp = e.pp;
     r.ast = root(e.ast, location = r.location); }


-- Binding Expressions
concrete productions e::Expr_Bnd_c
 | 'let' id::Id_t ':' ty::Type_Arrow_c '=' e1::Expr_Bnd_c 'in' e2::Expr_Bnd_c
   { e.pp = pp"let ${text(id.lexeme)} : ${ty.pp} = ${e1.pp} in ${e2.pp}";
     e.ast = let_expr (id_dcl (id.lexeme, location = id.location), ty.ast, e1.ast, e2.ast, 
                       location = e.location); }

 | 'lambda' i::Id_t ':' ty::Type_Arrow_c '.' e1::Expr_Bnd_c
   { e.pp = pp"lambda ${text(i.lexeme)} : ${ty.pp} . ${e1.pp}";
     e.ast = lambda_expr (id_dcl (i.lexeme, location = e.location), ty.ast, e1.ast,
                          location = e.location); }

 | ea::Expr_Add_c 
   { e.pp = ea.pp;
     e.ast = ea.ast; }


-- Additive expressions
concrete productions e::Expr_Add_c
 | e1::Expr_Add_c '+' t::Expr_Mul_c
   { e.pp = pp"${e1.pp} + ${t.pp}";
     e.ast = add_expr(e1.ast, t.ast, location = e.location); }

 | e1::Expr_Add_c '-' t::Expr_Mul_c
   { e.pp = pp"${e1.pp} - ${t.pp}";
     e.ast = sub_expr(e1.ast, t.ast, location = e.location); }

 | t::Expr_Mul_c
   { e.pp = t.pp;
     e.ast = t.ast; }


-- Multiplicative Expressions
concrete productions t::Expr_Mul_c
 | t1::Expr_Mul_c '*' f::Expr_App_c 
   { t.pp = pp"${t1.pp} * ${f.pp}";
     t.ast = mul_expr(t1.ast, f.ast, location = t.location); }

 | t1::Expr_Mul_c '/' f::Expr_App_c 
   { t.pp = pp"${t1.pp} / ${f.pp}";
     t.ast = div_expr(t1.ast, f.ast, location = t.location); }

 | f::Expr_App_c
   { t.pp = f.pp;
     t.ast = f.ast; }


-- Function application expressions
concrete productions e::Expr_App_c
 | e1::Expr_App_c e2::Expr_Prm_c 
   { e.pp = pp"${e1.pp} ${e2.pp}";
     e.ast = app_expr (e1.ast, e2.ast, location = e.location); }

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
     e.ast = ident(id_ref (i.lexeme, location = e.location), location = e.location); }

 | i::IntLit_t
   { e.pp = text(i.lexeme);
     e.ast = int_const (toInteger (i.lexeme), location = e.location); }

-- Types
concrete productions t::Type_Arrow_c
 | tp::Type_Prim_c '->' ta::Type_Arrow_c
   { t.pp = pp"${tp.pp} -> ${ta.pp}";
     t.ast = arrow_te (tp.ast, ta.ast, location = t.location); }

 | tp::Type_Prim_c
   { t.pp = tp.pp;
     t.ast = tp.ast; }

concrete productions t::Type_Prim_c
 | 'int'
   { t.pp = text("int");
     t.ast = int_te (location = t.location); }

 | '(' ta::Type_Arrow_c ')'
   { t.pp = pp"(${ta.pp})";
     t.ast = ta.ast; }

