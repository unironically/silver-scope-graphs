grammar lmr:lang;

{- Nonterminals -}
{-
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
-}

{- Attributes -}

inherited attribute s :: String 
  occurs on Decls, Decl, Super, SeqBinds, SeqBind, ParBinds, ParBind,
            Expr, FldBinds, FldBind, FldDecls, FldDecl, ArgDecl, Type,
            ModRef, TypeRef, VarRef;
inherited attribute s_rec :: String
  occurs on Super;
inherited attribute s_def :: String
  occurs on SeqBinds, SeqBind;

synthesized attribute const :: String
  occurs on Program, Decls, Decl, Super, ModRef, ParBind, FldDecls, TypeRef;

{- Program -}

aspect production program
top::Program ::= h::String ds::Decls
{
  local s :: String = exists ("s");

  top.const = and ("{" ++ s ++ "} " ++ new_scope (s), 
                ds.const);
  ds.s = s;
}

{- Decls -}

aspect production decls_list
top::Decls ::= d::Decl ds::Decls
{ 
  propagate s;

  top.const = and (d.const, 
                ds.const);
}

aspect production decls_empty
top::Decls ::= 
{
  top.const = "true";
}

{- Decl -}

aspect production decl_module
top::Decl ::= x::String ds::Decls
{
  local s_mod :: String = exists ("s_mod");

  top.const = and (new_scope_datum (s_mod, x, s_mod),
                and (edge (top.s, "`MOD", s_mod),
                  and (edge (s_mod, "`LEX", top.s), 
                    ds.const)));

  ds.s = s_mod;
}

aspect production decl_import
top::Decl ::= r::ModRef
{
  propagate s;
  local p :: String = exists ("p");
  local x :: String = exists ("r");
  local s_mod :: String = exists ("s_mod");

  top.const = and (r.const,
                and (datum (p, x, s_mod), 
                  edge (top.s, "`IMP", s_mod)));
}

aspect production decl_def
top::Decl ::= b::ParBind
{
  propagate s;

  top.const = b.const;
}

aspect production decl_rec
top::Decl ::= x::String sup::Super ds::FldDecls
{
  propagate s;
  local s_rec :: String = exists ("s_rec");

  top.const = and (new_scope_datum (s_rec, x, "REC(" ++ s_rec ++ ")"),
                and (edge (top.s, "`REC", s_rec),
                  and (sup.const,
                    ds.const)));

  sup.s_rec = s_rec;
}

{- Super -}

aspect production super_none
top::Super ::=
{
  top.const = "true";
}

aspect production super_some
top::Super ::= r::TypeRef
{
  propagate s;
  local p :: String = exists ("p");
  local x :: String = exists ("x");
  local s_sup :: String = exists ("s_sup");

  top.const = and (r.const,
                and (datum (p, x, "REC(" ++ s_sup ++ ")"),
                  edge (top.s_rec, "`EXT", s_sup)));
}

{- Seq_Binds -}

aspect production seq_binds_single
top::SeqBinds ::= b::SeqBind
{

}

aspect production seq_binds_list
top::SeqBinds ::= b::SeqBind bs::SeqBinds
{
}

{- Seq_Bind -}

aspect production seq_defbind
top::SeqBind ::= x::String e::Expr
{
}

aspect production seq_defbind_typed
top::SeqBind ::= x::String tyann::Type e::Expr
{
}

{- Par_Binds -}

aspect production par_binds_list
top::ParBinds ::= b::ParBind bs::ParBinds
{
}

aspect production par_binds_empty
top::ParBinds ::=
{
}

{- Par_Bind -}

aspect production par_defbind
top::ParBind ::= x::String e::Expr
{
}

aspect production par_defbind_typed
top::ParBind ::= x::String tyann::Type e::Expr
{
}

{- Expr -}

aspect production expr_int
top::Expr ::= i::Integer
{
}

aspect production expr_bool
top::Expr ::= b::Boolean
{
}

aspect production expr_var
top::Expr ::= r::VarRef
{
}

aspect production expr_add
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_sub
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_mul
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_div
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_and
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_or
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_eq
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_app
top::Expr ::= e1::Expr e2::Expr
{
}

aspect production expr_if
top::Expr ::= e1::Expr e2::Expr e3::Expr
{
}

aspect production expr_fun
top::Expr ::= d::ArgDecl e::Expr
{
}

aspect production expr_let
top::Expr ::= bs::SeqBinds e::Expr
{
}

aspect production expr_letrec
top::Expr ::= bs::ParBinds e::Expr
{
}

aspect production expr_letpar
top::Expr ::= bs::ParBinds e::Expr
{
}

aspect production expr_new
top::Expr ::= r::TypeRef bs::FldBinds
{
}

aspect production expr_fld_access
top::Expr ::= e::Expr x::String
{
}

aspect production expr_with
top::Expr ::= e1::Expr e2::Expr
{
}

{- Fld_Binds -}

aspect production fld_binds_list
top::FldBinds ::= b::FldBind bs::FldBinds
{
}

aspect production fld_binds_empty
top::FldBinds ::=
{
}

{- Fld_Bind -}

aspect production fld_bind
top::FldBind ::= x::String e::Expr
{
}

{- Fld_Decls -}

aspect production fld_decls_list
top::FldDecls ::= d::FldDecl ds::FldDecls
{
}

aspect production fld_decls_empty
top::FldDecls ::=
{
}

{- Fld_Decl -}

aspect production fld_decl
top::FldDecl ::= x::String tyann::Type
{
}

{- Arg_Decl -}

aspect production arg_decl
top::ArgDecl ::= x::String tyann::Type
{
}

{- Type -}

aspect production type_int
top::Type ::= 
{
}

aspect production type_bool
top::Type ::=
{
}

aspect production type_arrow
top::Type ::= tyann1::Type tyann2::Type
{
}

aspect production type_rec
top::Type ::= r::TypeRef
{
}

{- Mod_Ref -}

aspect production mod_ref_single
top::ModRef ::= x::String
{
}

aspect production mod_ref_dot
top::ModRef ::= r::ModRef x::String
{
}

{- Type_Ref -}

aspect production type_ref_single
top::TypeRef ::= x::String
{
}

aspect production type_ref_dot
top::TypeRef ::= r::ModRef x::String
{
}

{- Var_Ref -}

aspect production var_ref_single
top::VarRef ::= x::String
{
}

aspect production var_ref_dot
top::VarRef ::= r::ModRef x::String
{
}

{- Functions -}

function and
String ::= c::String cs::String
{
  return c ++ ", " ++ cs;
}

function new_scope
String ::= name::String
{
  return "new " ++ name;
}

function new_scope_datum
String ::= name::String datum_id::String datum_t::String
{
  return "new " ++ name ++ " -> (" ++ datum_id ++ ", " ++ datum_t ++ ")";
}

function edge
String ::= src::String lab::String dst::String
{
  return src ++ " -[ " ++ lab ++ " ]- " ++ dst;
}

function exists
String ::= x::String
{
  return x ++ "_" ++ toString (genInt ());
}

function datum
String ::= p::String d_id::String d_t::String
{
  return
    let s :: String = exists ("s") in
      "{" ++ s ++ "}" ++ " tgt(" ++ p ++ ", " ++ s ++ "), " ++ s ++ " -> " ++
      "(" ++ d_id ++ ", " ++ d_t ++ ")"
    end;
}

function min_refs
String ::= z1::String z2::String
{
  return
    "min " ++ z1 ++ " lexico ( `MOD < `LEX, `MOD < `IMP, `MOD < `EXT," ++ 
                              "`REC < `LEX, `REC < `IMP, `REC < `EXT," ++
                              "`VAR < `LEX, `VAR < `IMP, `VAR < `EXT," ++
                              "`IMP < `LEX, `EXT < `LEX" ++ 
                            ") " ++ z2;
}