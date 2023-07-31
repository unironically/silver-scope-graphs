grammar scope_tree_generic:lmr;

imports scope_tree_generic:ast;

{- Nonterminals -}

nonterminal Program;
nonterminal Decls;
nonterminal Decl;
nonterminal Super;
nonterminal SeqBinds;
nonterminal SeqBind;
nonterminal ParBinds;
nonterminal ParBind;
nonterminal Expr;
nonterminal FldBinds;
nonterminal FldBind;
nonterminal FldDecls;
nonterminal FldDecl;
nonterminal ArgDecl;
nonterminal Type;
nonterminal ModRef;
nonterminal TypeRef;
nonterminal VarRef;

{- Attributes -}


{- Program -}

abstract production program
top::Program ::= h::String ds::Decls
{}

{- Decls -}

abstract production decls_list
top::Decls ::= d::Decl ds::Decls
{}

abstract production decls_empty
top::Decls ::= 
{}

{- Decl -}

abstract production decl_module
top::Decl ::= x::String ds::Decls
{}

abstract production decl_import
top::Decl ::= r::ModRef
{}

abstract production decl_def
top::Decl ::= b::ParBind
{}

abstract production decl_rec
top::Decl ::= x::String sup::Super ds::FldDecls
{}

{- Super -}

abstract production super_none
top::Super ::=
{}

abstract production super_some
top::Super ::= r::TypeRef
{}

{- Seq_Binds -}

abstract production seq_binds_empty
top::SeqBinds ::=
{}

abstract production seq_binds_single
top::SeqBinds ::= b::SeqBind
{}

abstract production seq_binds_list
top::SeqBinds ::= b::SeqBind bs::SeqBinds
{}

{- Seq_Bind -}

abstract production seq_defbind
top::SeqBind ::= x::String e::Expr
{}

abstract production seq_defbind_typed
top::SeqBind ::= x::String tyann::Type e::Expr
{}

{- Par_Binds -}

abstract production par_binds_list
top::ParBinds ::= b::ParBind bs::ParBinds
{}

abstract production par_binds_empty
top::ParBinds ::=
{}

{- Par_Bind -}

abstract production par_defbind
top::ParBind ::= x::String e::Expr
{}

abstract production par_defbind_typed
top::ParBind ::= x::String tyann::Type e::Expr
{}

{- Expr -}

abstract production expr_int
top::Expr ::= i::Integer
{}

abstract production expr_bool
top::Expr ::= b::Boolean
{}

abstract production expr_var
top::Expr ::= r::VarRef
{}

abstract production expr_add
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_sub
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_mul
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_div
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_and
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_or
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_eq
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_app
top::Expr ::= e1::Expr e2::Expr
{}

abstract production expr_if
top::Expr ::= e1::Expr e2::Expr e3::Expr
{}

abstract production expr_fun
top::Expr ::= d::ArgDecl e::Expr
{}

abstract production expr_let
top::Expr ::= bs::SeqBinds e::Expr
{
}

abstract production expr_letrec
top::Expr ::= bs::ParBinds e::Expr
{
}

abstract production expr_letpar
top::Expr ::= bs::ParBinds e::Expr
{
}

abstract production expr_new
top::Expr ::= r::TypeRef bs::FldBinds
{
}

abstract production expr_fld_access
top::Expr ::= e::Expr x::String
{
}

abstract production expr_with
top::Expr ::= e1::Expr e2::Expr
{
}

{- Fld_Binds -}

abstract production fld_binds_list
top::FldBinds ::= b::FldBind bs::FldBinds
{
}

abstract production fld_binds_empty
top::FldBinds ::=
{
}
{- Fld_Bind -}

abstract production fld_bind
top::FldBind ::= x::String e::Expr
{
}

{- Fld_Decls -}

abstract production fld_decls_list
top::FldDecls ::= d::FldDecl ds::FldDecls
{
}

abstract production fld_decls_empty
top::FldDecls ::=
{
}

{- Fld_Decl -}

abstract production fld_decl
top::FldDecl ::= x::String tyann::Type
{
}

{- Arg_Decl -}

abstract production arg_decl
top::ArgDecl ::= x::String tyann::Type
{
}

{- Type -}

abstract production type_int
top::Type ::= 
{
}

abstract production type_bool
top::Type ::=
{
}

abstract production type_arrow
top::Type ::= tyann1::Type tyann2::Type
{
}

abstract production type_rec
top::Type ::= r::TypeRef
{
}

{- Mod_Ref -}

abstract production mod_ref_single
top::ModRef ::= x::String
{
}

abstract production mod_ref_dot
top::ModRef ::= r::ModRef x::String
{
}

{- Type_Ref -}

abstract production type_ref_single
top::TypeRef ::= x::String
{
}

abstract production type_ref_dot
top::TypeRef ::= r::ModRef x::String
{
}

{- Var_Ref -}

abstract production var_ref_single
top::VarRef ::= x::String
{
}

abstract production var_ref_dot
top::VarRef ::= r::ModRef x::String
{
}