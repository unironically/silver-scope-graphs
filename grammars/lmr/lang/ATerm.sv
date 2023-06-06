grammar lmr:lang;

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

synthesized attribute pp :: String 
  occurs on Program, Decls, Decl, Super, 
    SeqBinds, SeqBind, ParBinds, ParBind, Expr, FldBinds, FldBind, 
    FldDecls, FldDecl, ArgDecl, Type, ModRef, TypeRef, VarRef;

{- Program -}

abstract production program
top::Program ::= h::String ds::Decls
{
  top.pp = "Program (\"" ++ h ++ "\", [" ++ ds.pp ++ "])\n";
}

{- Decls -}

abstract production decls_list
top::Decls ::= d::Decl ds::Decls
{
  top.pp = d.pp ++ (case ds of 
                   | decls_empty () -> ""
                   | decls_list (_, _) -> ", " ++ ds.pp
                   end);
}

abstract production decls_empty
top::Decls ::= 
{
  top.pp = "";
}

{- Decl -}

abstract production decl_module
top::Decl ::= x::String ds::Decls
{
  top.pp = "Module (\"" ++ x ++ "\", " ++ ds.pp ++ ")";
}

abstract production decl_import
top::Decl ::= r::ModRef
{
  top.pp = "Import (" ++ r.pp ++ ")";
}

abstract production decl_def
top::Decl ::= b::ParBind
{
  top.pp = "Def (" ++ b.pp ++ ")";
}

abstract production decl_rec
top::Decl ::= x::String sup::Super ds::FldDecls
{
  top.pp = "Rec (\"" ++ x ++ "\"," ++ sup.pp ++ ", " ++ ds.pp ++ ")";
}

{- Super -}

abstract production super_none
top::Super ::=
{
  top.pp = "NoSuper()";
}

abstract production super_some
top::Super ::= r::TypeRef
{
  top.pp = "Super";
}

{- Seq_Binds -}

abstract production seq_binds_empty
top::SeqBinds ::=
{
  top.pp = "";
}

abstract production seq_binds_single
top::SeqBinds ::= b::SeqBind
{
  top.pp = b.pp;
}

abstract production seq_binds_list
top::SeqBinds ::= b::SeqBind bs::SeqBinds
{
  top.pp = b.pp ++ ", " ++ bs.pp;
}

{- Seq_Bind -}

abstract production seq_defbind
top::SeqBind ::= x::String e::Expr
{
  top.pp = "DefBind (\"" ++ x ++ "\", " ++ e.pp ++ ")";
}

abstract production seq_defbind_typed
top::SeqBind ::= x::String tyann::Type e::Expr
{
  top.pp = "DefBindTyped (\"" ++ x ++ "\", " ++ tyann.pp ++ ", " ++ e.pp ++ ")";
}

{- Par_Binds -}

abstract production par_binds_list
top::ParBinds ::= b::ParBind bs::ParBinds
{
  top.pp = b.pp ++ (case bs of 
                   | par_binds_empty () -> ""
                   | par_binds_list (_, _) -> "," ++ bs.pp
                   end);
}

abstract production par_binds_empty
top::ParBinds ::=
{
  top.pp = "";
}

{- Par_Bind -}

abstract production par_defbind
top::ParBind ::= x::String e::Expr
{
  top.pp = "DefBind (\"" ++ x ++ "\", " ++ e.pp ++ ")";
}

abstract production par_defbind_typed
top::ParBind ::= x::String tyann::Type e::Expr
{
  top.pp = "DefBindTyped (\"" ++ x ++ "\", " ++ tyann.pp ++ ", " ++ e.pp ++ ")";
}

{- Expr -}

abstract production expr_int
top::Expr ::= i::Integer
{
  top.pp = "Int (\"" ++ toString (i) ++ "\")";
}

abstract production expr_bool
top::Expr ::= b::Boolean
{
  top.pp = if b then "True ()" else "False ()";
}

abstract production expr_var
top::Expr ::= r::VarRef
{
  top.pp = "Var (" ++ r.pp ++ ")";
}

abstract production expr_add
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "Add (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_sub
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "Sub (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_mul
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "Mul (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_div
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "Div (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_and
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "And (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_or
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "Or (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_eq
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "Eq (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_app
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "App (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

abstract production expr_if
top::Expr ::= e1::Expr e2::Expr e3::Expr
{
  top.pp = "If (" ++ e1.pp ++ ", " ++ e2.pp ++ ", " ++ e3.pp ++ ")";
}

abstract production expr_fun
top::Expr ::= d::ArgDecl e::Expr
{
  top.pp = "Fun (" {-++ d.pp-} ++ ", " ++ e.pp ++ ")";
}

abstract production expr_let
top::Expr ::= bs::SeqBinds e::Expr
{
  top.pp = "Let ([" ++ bs.pp ++ "], " ++ e.pp ++ ")";
}

abstract production expr_letrec
top::Expr ::= bs::ParBinds e::Expr
{
  top.pp = "LetRec ([" ++ bs.pp ++ "], " ++ e.pp ++ ")";
}

abstract production expr_letpar
top::Expr ::= bs::ParBinds e::Expr
{
  top.pp = "LetPar ([" ++ bs.pp ++ "], " ++ e.pp ++ ")";
}

abstract production expr_new
top::Expr ::= r::TypeRef bs::FldBinds
{
  top.pp = "New (" ++ r.pp ++ ", [" ++ bs.pp ++ "])";
}

abstract production expr_fld_access
top::Expr ::= e::Expr x::String
{
  top.pp = "FldAccess (" ++ e.pp ++ ", \"" ++ x ++ "\")";
}

abstract production expr_with
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = "With (" ++ e1.pp ++ ", " ++ e2.pp ++ ")";
}

{- Fld_Binds -}

abstract production fld_binds_list
top::FldBinds ::= b::FldBind bs::FldBinds
{
  top.pp = b.pp ++ (case bs of 
                   | fld_binds_empty () -> ""
                   | fld_binds_list (_, _) -> ", " ++ bs.pp
                   end);
}

abstract production fld_binds_empty
top::FldBinds ::=
{
  top.pp = "";
}

{- Fld_Bind -}

abstract production fld_bind
top::FldBind ::= x::String e::Expr
{
  top.pp = "FldBind (\"" ++ x ++ "\", " ++ e.pp ++ ")";
}

{- Fld_Decls -}

abstract production fld_decls_list
top::FldDecls ::= d::FldDecl ds::FldDecls
{
  top.pp = d.pp ++ (case ds of
                   | fld_decls_empty () -> ""
                   | fld_decls_list (_, _) -> ", " ++ ds.pp
                   end);
}

abstract production fld_decls_empty
top::FldDecls ::=
{
  top.pp = "";
}

{- Fld_Decl -}

abstract production fld_decl
top::FldDecl ::= x::String tyann::Type
{
  top.pp = "ArgDecl (\"" ++ x ++ "\", " ++ tyann.pp ++ ")";
}

{- Arg_Decl -}

abstract production arg_decl
top::ArgDecl ::= x::String tyann::Type
{
  top.pp = "ArgDecl (\"" ++ x ++ "\", " ++ tyann.pp ++ ")";
}

{- Type -}

abstract production type_int
top::Type ::= 
{
  top.pp = "TInt ()";
}

abstract production type_bool
top::Type ::=
{
  top.pp = "TBool ()";
}

abstract production type_arrow
top::Type ::= tyann1::Type tyann2::Type
{
  top.pp = "TArrow (" ++ tyann1.pp ++ ", " ++ tyann2.pp ++ ")";
}

abstract production type_rec
top::Type ::= r::TypeRef
{
  top.pp = "TRec (" ++ r.pp ++ ")";
}

{- Mod_Ref -}

abstract production mod_ref_single
top::ModRef ::= x::String
{
  top.pp = "ModRef (\"" ++ x ++ "\")";
}

abstract production mod_ref_dot
top::ModRef ::= r::ModRef x::String
{
  top.pp = "ModQRef (" ++ r.pp ++ ", \"" ++ x ++ "\")";
}

{- Type_Ref -}

abstract production type_ref_single
top::TypeRef ::= x::String
{
  top.pp = "TypeRef (\"" ++ x ++ "\")";
}

abstract production type_ref_dot
top::TypeRef ::= r::ModRef x::String
{
  top.pp = "TypeQRef (" ++ r.pp ++ ", \"" ++ x ++ "\")";
}

{- Var_Ref -}

abstract production var_ref_single
top::VarRef ::= x::String
{
  top.pp = "VarRef (\"" ++ x ++ "\")";
}

abstract production var_ref_dot
top::VarRef ::= r::ModRef x::String
{
  top.pp = "VarQRef (" ++ r.pp ++ ", \"" ++ x ++ "\")";
}