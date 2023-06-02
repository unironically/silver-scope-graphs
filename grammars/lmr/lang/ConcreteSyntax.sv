grammar lmr:lang;

synthesized attribute ast<a> :: a;

nonterminal Program_c   with ast<Program>;
nonterminal Decls_c     with ast<Decls>;
nonterminal Decl_c      with ast<Decl>;
nonterminal Super_c     with ast<Super>;
nonterminal SeqBinds_c  with ast<SeqBinds>;
nonterminal SeqBind_c   with ast<SeqBind>;
nonterminal ParBinds_c  with ast<ParBinds>;
nonterminal ParBind_c   with ast<ParBind>;
nonterminal Expr_c      with ast<Expr>;
nonterminal FldBinds_c  with ast<FldBinds>;
nonterminal FldBind_c   with ast<FldBind>;
nonterminal FldDecls_c  with ast<FldDecls>;
nonterminal FldDecl_c   with ast<FldDecl>;
nonterminal ArgDecl_c   with ast<ArgDecl>;
nonterminal Type_c      with ast<Type>;
nonterminal ModRef_c    with ast<ModRef>;
nonterminal TypeRef_c   with ast<TypeRef>;
nonterminal VarRef_c    with ast<VarRef>;

{- Program -}

concrete production program_c
top::Program_c ::= ds::Decls_c
{
  top.ast = program ("prog", ds.ast);
}

{- Decls -}

concrete production decls_list_c
top::Decls_c ::= d::Decl_c ';' ds::Decls_c
{
  top.ast = decls_list (d.ast, ds.ast);
}

concrete production decls_empty_c
top::Decls_c ::= 
{
  top.ast = decls_empty ();
}

{- Decl -}

concrete production decl_module_c
top::Decl_c ::= 'module' id::Id_t '{' ds::Decls_c '}'
{
  top.ast = decl_module (id.lexeme, ds.ast);
}

concrete production decl_import_c
top::Decl_c ::= 'import' r::ModRef_c
{
  top.ast = decl_import (r.ast);
}

concrete production decl_def_c
top::Decl_c ::= 'def' b::ParBind_c
{
  top.ast = decl_def (b.ast);
}

concrete production decl_rec_c
top::Decl_c ::= 'record' id::Id_t sup::Super_c '{' ds::FldDecls_c '}'
{
  top.ast = decl_rec (id.lexeme, sup.ast, ds.ast);
}

{- Super -}

concrete production super_none_c
top::Super_c ::=
{
  top.ast = super_none ();
}

concrete production super_some_c
top::Super_c ::= t::TypeRef_c
{
  top.ast = super_some (t.ast);
}

{- Seq_Binds -}
concrete production seq_binds_empty_c
top::SeqBinds_c ::=
{
  top.ast = seq_binds_empty ();
}

concrete production seq_binds_single_c
top::SeqBinds_c ::= b::SeqBind_c
{
  top.ast = seq_binds_single (b.ast);
}

concrete production seq_binds_list_c
top::SeqBinds_c ::= b::SeqBind_c bs::SeqBinds_c
{
  top.ast = seq_binds_list (b.ast, bs.ast);
}

{- Seq_Bind -}

concrete production seq_defbind_c
top::SeqBind_c ::= x::Id_t '=' e::Expr_c
{
  top.ast = seq_defbind (x.lexeme, e.ast);
}

concrete production seq_defbind_typed_c
top::SeqBind_c ::= x::Id_t ':' tyann::Type_c '=' e::Expr_c
{
  top.ast = seq_defbind_typed (x.lexeme, tyann.ast, e.ast);
}

{- Par_Binds -}

concrete production par_binds_list_c
top::ParBinds_c ::= b::ParBind_c bs::ParBinds_c
{
  top.ast = par_binds_list (b.ast, bs.ast);
}

concrete production par_binds_empty_c
top::ParBinds_c ::=
{
  top.ast = par_binds_empty ();
}

{- Par_Bind -}

concrete production par_defbind_c
top::ParBind_c ::= x::Id_t '=' e::Expr_c
{
  top.ast = par_defbind (x.lexeme, e.ast);
}

concrete production par_defbind_typed_c
top::ParBind_c ::= x::Id_t ':' tyann::Type_c '=' e::Expr_c
{
  top.ast = par_defbind_typed (x.lexeme, tyann.ast, e.ast);
}

{- Expr -}

concrete production expr_int_c
top::Expr_c ::= i::Int_t
{
  local real :: Integer = (case toIntSafe (i.lexeme) of 
                            | just (i) -> i
                            | nothing () -> -1
                          end);
  top.ast = expr_int (real);
}

concrete production expr_true_c
top::Expr_c ::= 'true'
{
  top.ast = expr_bool (true);
}

concrete production expr_false_c
top::Expr_c ::= 'false'
{
  top.ast = expr_bool (false);
}

concrete production expr_var_c
top::Expr_c ::= r::VarRef_c
{
  top.ast = expr_var (r.ast);
}

concrete production expr_add_c
top::Expr_c ::= e1::Expr_c '+' e2::Expr_c
{
  top.ast = expr_add (e1.ast, e2.ast);
}

concrete production expr_sub_c
top::Expr_c ::= e1::Expr_c '-' e2::Expr_c
{
  top.ast = expr_sub (e1.ast, e2.ast);
}

concrete production expr_mul_c
top::Expr_c ::= e1::Expr_c '*' e2::Expr_c
{
  top.ast = expr_mul (e1.ast, e2.ast);
}

concrete production expr_div_c
top::Expr_c ::= e1::Expr_c '/' e2::Expr_c
{
  top.ast = expr_div (e1.ast, e2.ast);
}

concrete production expr_and_c
top::Expr_c ::= e1::Expr_c '&' e2::Expr_c
{
  top.ast = expr_and (e1.ast, e2.ast);
}

concrete production expr_or_c
top::Expr_c ::= e1::Expr_c '|' e2::Expr_c
{
  top.ast = expr_or (e1.ast, e2.ast);
}

concrete production expr_eq_c
top::Expr_c ::= e1::Expr_c '==' e2::Expr_c
{
  top.ast = expr_eq (e1.ast, e2.ast);
}

concrete production expr_app_c
top::Expr_c ::= e1::Expr_c App_t e2::Expr_c
{
  top.ast = expr_app (e1.ast, e2.ast);
}

concrete production expr_if_c
top::Expr_c ::= 'if' e1::Expr_c 'then' e2::Expr_c 'else' e3::Expr_c
{
  top.ast = expr_if (e1.ast, e2.ast, e3.ast);
}

concrete production expr_fun_c
top::Expr_c ::= 'fun' '(' d::ArgDecl_c ')' '{' e::Expr_c '}'
{
  top.ast = expr_fun (d.ast, e.ast);
}

concrete production expr_let_c
top::Expr_c ::= 'let' bs::SeqBinds_c 'in' e::Expr_c
{
  top.ast = expr_let (bs.ast, e.ast);
}

concrete production expr_letrec_c
top::Expr_c ::= 'letrec' bs::ParBinds_c 'in' e::Expr_c
{
  top.ast = expr_letrec (bs.ast, e.ast);
}

concrete production expr_letpar_c
top::Expr_c ::= 'letpar' bs::ParBinds_c 'in' e::Expr_c
{
  top.ast = expr_letpar (bs.ast, e.ast);
}

concrete production expr_new_c
top::Expr_c ::= 'new' r::TypeRef_c '{' bs::FldBinds_c '}'
{
  top.ast = expr_new (r.ast, bs.ast);
}

concrete production expr_fld_access_c
top::Expr_c ::= e::Expr_c '.' x::Id_t
{
  top.ast = expr_fld_access (e.ast, x.lexeme);
}

concrete production expr_with_c
top::Expr_c ::= 'with' e1::Expr_c 'do' e2::Expr_c
{
  top.ast = expr_with (e1.ast, e2.ast);
}

concrete production expr_bracket_c
top::Expr_c ::= '(' e::Expr_c ')'
{
  top.ast = e.ast;
}

{- Fld_Binds -}

concrete production fld_binds_list_c
top::FldBinds_c ::= b::FldBind_c '.' bs::FldBinds_c
{
  top.ast = fld_binds_list (b.ast, bs.ast);
}

concrete production fld_binds_empty_c
top::FldBinds_c ::=
{
  top.ast = fld_binds_empty ();
}

{- Fld_Bind -}

concrete production fld_bind_c
top::FldBind_c ::= x::Id_t '=' e::Expr_c
{
  top.ast = fld_bind (x.lexeme, e.ast);
}

{- Fld_Decls -}

concrete production fld_decls_list_c
top::FldDecls_c ::= d::FldDecl_c ',' ds::FldDecls_c
{
  top.ast = fld_decls_list (d.ast, ds.ast);
}

concrete production fld_decls_empty_c
top::FldDecls_c ::=
{
  top.ast = fld_decls_empty ();
}

{- Fld_Decl -}

concrete production fld_decl_c
top::FldDecl_c ::= x::Id_t ':' tyann::Type_c
{
  top.ast = fld_decl (x.lexeme, tyann.ast);
}

{- Arg_Decl -}

concrete production arg_decl_c
top::ArgDecl_c ::= x::Id_t ':' tyann::Type_c
{
  top.ast = arg_decl (x.lexeme, tyann.ast);
}

{- Type -}

concrete production type_int_c
top::Type_c ::= 'int'
{
  top.ast = type_int ();
}

concrete production type_bool_c
top::Type_c ::= 'bool'
{
  top.ast = type_bool ();
}

concrete production type_arrow_c
top::Type_c ::= tyann1::Type_c '->' tyann2::Type_c
{
  top.ast = type_arrow (tyann1.ast, tyann2.ast);
}

concrete production type_rec_c
top::Type_c ::= r::TypeRef_c
{
  top.ast = type_rec (r.ast);
}

concrete production type_bracket_c
top::Type_c ::= '(' t::Type_c ')'
{
  top.ast = t.ast;
}

{- Mod_Ref -}

concrete production mod_ref_single_c
top::ModRef_c ::= x::Id_t
{
  top.ast = mod_ref_single (x.lexeme);
}

concrete production mod_ref_dot_c
top::ModRef_c ::= r::ModRef_c '.' x::Id_t
{
  top.ast = mod_ref_dot (r.ast, x.lexeme);
}

{- Type_Ref -}

concrete production type_ref_single_c
top::TypeRef_c ::= x::Id_t
{
  top.ast = type_ref_single (x.lexeme);
}

concrete production type_ref_dot_c
top::TypeRef_c ::= r::TypeRef_c '.' x::Id_t
{
  top.ast = type_ref_dot (r.ast, x.lexeme);
}

{- Var_Ref -}

concrete production var_ref_single_c
top::VarRef_c ::= x::Id_t
{
  top.ast = var_ref_single (x.lexeme);
}

{-
For Eric

concrete production var_ref_dot_c
top::VarRef_c ::= r::VarRef_c '.' x::Id_t
{
  top.ast = var_ref_dot (r.ast, x.lexeme);
}-} 