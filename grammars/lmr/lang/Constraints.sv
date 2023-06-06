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
  occurs on Super, FldBinds, FldBind;
inherited attribute s_def :: String
  occurs on SeqBinds, SeqBind, ParBinds, ParBind;
inherited attribute ty :: String
  occurs on Expr, Type, ArgDecl;
inherited attribute p :: String
  occurs on VarRef, TypeRef, ModRef;

synthesized attribute const :: String
  occurs on Program, Decls, Decl, Super, ModRef, ParBind, FldDecls, TypeRef,
            SeqBinds, SeqBind, Expr, Type, ParBinds, VarRef, ArgDecl,
            FldBinds, FldBind, FldDecl;

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
aspect production seq_binds_empty
top::SeqBinds ::=
{
  top.const = edge (top.s_def, "`LEX", top.s);
}

aspect production seq_binds_single
top::SeqBinds ::= b::SeqBind
{
  propagate s, s_def;
  top.const = and (edge (top.s_def, "`LEX", top.s),
                b.const);
}

aspect production seq_binds_list
top::SeqBinds ::= b::SeqBind bs::SeqBinds
{
  local s_def_prime :: String = exists ("s_def'");
  top.const = and (new_scope (s_def_prime),
                and (edge (s_def_prime, "`LEX", top.s), 
                  and (b.const,
                    bs.const)));
  b.s = top.s;
  b.s_def = s_def_prime;
  bs.s = s_def_prime;
  bs.s_def = top.s_def;
}

{- Seq_Bind -}

aspect production seq_defbind
top::SeqBind ::= x::String e::Expr
{
  local s_var :: String = exists ("s_var");
  local ty :: String = exists ("ty");
  top.const = and (new_scope_datum (s_var, x, ty),
                and (edge (top.s, "`VAR", s_var),
                  e.const));
  e.s = top.s;
  e.ty = ty;
}

aspect production seq_defbind_typed
top::SeqBind ::= x::String tyann::Type e::Expr
{
  local s_var :: String = exists ("s_var");
  local ty :: String = exists ("ty");
  top.const = and (new_scope_datum (s_var, x, ty),
                and (edge (top.s, "`VAR", s_var),
                  and (tyann.const,
                    e.const)));
  tyann.s = top.s;
  tyann.ty = ty;
  e.s = top.s;
  e.ty = ty; 
}

{- Par_Binds -}

aspect production par_binds_list
top::ParBinds ::= b::ParBind bs::ParBinds
{
  propagate s, s_def;
  top.const = and (b.const, bs.const);
}

aspect production par_binds_empty
top::ParBinds ::=
{
  top.const = "true";
}

{- Par_Bind -}

aspect production par_defbind
top::ParBind ::= x::String e::Expr
{
  local s_var :: String = exists ("s_var");
  local ty :: String = exists ("ty");
  top.const = and (new_scope_datum (s_var, x, ty),
                and (edge (top.s_def, "`VAR", s_var),
                  e.const));
  e.s = top.s;
  e.ty = ty;
}

aspect production par_defbind_typed
top::ParBind ::= x::String tyann::Type e::Expr
{
  local s_var :: String = exists ("s_var");
  local ty :: String = exists ("ty");
  top.const = and (new_scope_datum (s_var, x, ty),
                and (edge (top.s_def, "`VAR", s_var),
                  and (tyann.const,
                    e.const)));
  tyann.s = top.s;
  tyann.ty = ty;
  e.s = top.s;
  e.ty = ty;
}

{- Expr -}

aspect production expr_int
top::Expr ::= i::Integer
{
  top.const = eq (top.ty, "INT()");
}

aspect production expr_bool
top::Expr ::= b::Boolean
{
  top.const = eq (top.ty, "BOOL()");
}

aspect production expr_var
top::Expr ::= r::VarRef
{
  local p :: String = exists ("p");
  local x :: String = exists ("x");
  top.const = and (r.const,
                datum (p, x, top.ty));
  r.s = top.s;
  r.p = p;
}

aspect production expr_add
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  eq (top.ty, "INT()")));
  e1.ty = "INT()";
  e2.ty = "INT()";
}

aspect production expr_sub
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  eq (top.ty, "INT()")));
  e1.ty = "INT()";
  e2.ty = "INT()";
}

aspect production expr_mul
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  eq (top.ty, "INT()")));
  e1.ty = "INT()";
  e2.ty = "INT()";
}

aspect production expr_div
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  eq (top.ty, "INT()")));
  e1.ty = "INT()";
  e2.ty = "INT()";
}

aspect production expr_and
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  eq (top.ty, "BOOL()")));
  e1.ty = "BOOL()";
  e2.ty = "BOOL()";
}

aspect production expr_or
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  eq (top.ty, "BOOL()")));
  e1.ty = "BOOL()";
  e2.ty = "BOOL()";
}

aspect production expr_eq
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  local ty_prime :: String = exists ("ty'");
  top.const = and (e1.const,
                and (e2.const,
                  and ("true",
                    eq (top.ty, "BOOL()"))));
  e1.ty = ty_prime;
  e2.ty = ty_prime;
}

aspect production expr_app
top::Expr ::= e1::Expr e2::Expr
{
  propagate s;
  local ty1 :: String = exists ("ty1");
  top.const = and (e1.const,
                and (e2.const,
                  "true"));
  e1.ty = "FUN(" ++ ty1 ++ ", " ++ top.ty ++ ")";
  e2.ty = ty1;
}

aspect production expr_if
top::Expr ::= e1::Expr e2::Expr e3::Expr
{
  propagate s;
  top.const = and (e1.const,
                and (e2.const,
                  and (e3.const,
                    "true")));
  e1.ty = "BOOL()";
  e2.ty = top.ty;
  e3.ty = top.ty;
}

aspect production expr_fun
top::Expr ::= d::ArgDecl e::Expr
{
  local s_fun :: String = exists ("s_fun");
  local ty1 :: String = exists ("ty1");
  local ty2 :: String = exists ("ty2");
  top.const = and (new_scope (s_fun),
                and (edge (s_fun, "`LEX", top.s),
                  and (d.const,
                    and (e.const,
                      eq (top.ty, "FUN(" ++ ty1 ++ ", " ++ ty2 ++ ")")))));
  d.s = s_fun;
  d.ty = ty1;
  e.s = s_fun;
  e.ty = ty2;
}

aspect production expr_let
top::Expr ::= bs::SeqBinds e::Expr
{
  local s_let :: String = exists ("s_let");
  top.const = and (new_scope (s_let),
                and (bs.const,
                  e.const));
  bs.s = top.s;
  bs.s_def = s_let;
  e.s = s_let;
  e.ty = top.ty;
}

aspect production expr_letrec
top::Expr ::= bs::ParBinds e::Expr
{
  local s_let :: String = exists ("s_let");
  top.const = and (new_scope (s_let),
                and (edge (s_let, "`LEX", top.s),
                  and (bs.const,
                    e.const)));
  bs.s = s_let;
  bs.s_def = s_let;
  e.s = s_let;
  e.ty = top.ty;
}

aspect production expr_letpar
top::Expr ::= bs::ParBinds e::Expr
{
  local s_let :: String = exists ("s_let");
  top.const = and (new_scope (s_let),
                and (edge (s_let, "`LEX", top.s),
                  and (bs.const,
                    e.const)));
  bs.s = top.s;
  bs.s_def = s_let;
  e.s = s_let;
  e.ty = top.ty;
}

aspect production expr_new
top::Expr ::= r::TypeRef bs::FldBinds
{
  local p :: String = exists ("p");
  local x :: String = exists ("x");
  local s_rec :: String = exists ("s_rec");
  top.const = and (r.const,
                and (datum (p, x, top.ty),
                  and (eq (top.ty, "REC(" ++ s_rec ++ ")"),
                    bs.const)));
  r.s = top.s;
  r.p = p;
  bs.s = top.s;
  bs.s_rec = s_rec;
}

aspect production expr_fld_access
top::Expr ::= e::Expr x::String
{
  local s_rec :: String = exists ("s_rec");
  local flds :: String = exists ("flds");
  local xflds :: String = exists ("xflds");
  local xflds_prime :: String = exists ("xflds'");
  local p :: String = exists ("p");
  top.const = and (e.const,
                and (query (top.s, "`EXT* `FLD", flds),
                  and (filt (flds, "((x', _) where x' == " ++ x ++ ")", xflds),
                    and (min_refs (xflds, xflds_prime),
                      and (onl (xflds_prime, p),
                        datum (p, x, top.ty))))));
 e.s = top.s;
 e.ty = "REC(" ++ s_rec ++ ")";
}

aspect production expr_with
top::Expr ::= e1::Expr e2::Expr
{
  local s_with :: String = exists ("s_with");
  local s_rec :: String = exists ("s_rec");
  top.const = and (e1.const,
                and (new_scope (s_with),
                  and (edge (s_with, "`EXT", s_rec),
                    e2.const)));
  e1.s = top.s;
  e1.ty = "REC(" ++ s_rec ++ ")";
  e2.s = s_with;
  e2.ty = top.ty;
}

{- Fld_Binds -}

aspect production fld_binds_list
top::FldBinds ::= b::FldBind bs::FldBinds
{
  propagate s, s_rec;
  top.const = and (b.const, bs.const);
}

aspect production fld_binds_empty
top::FldBinds ::=
{
  top.const = "true";
}

{- Fld_Bind -}

aspect production fld_bind
top::FldBind ::= x::String e::Expr
{
  propagate s;
  local ty :: String = exists ("ty");
  local flds :: String = exists ("flds");
  local xflds :: String = exists ("xflds");
  local xflds_prime :: String = exists ("xflds'");
  local p :: String = exists ("p");
  top.const = and (e.const,
                and (query (top.s_rec, "`EXT* `FLD", flds),
                  and (filt (flds, "((x', _) where x' == " ++ x ++ ")", xflds),
                    and (min_refs (xflds, xflds_prime),
                      and (onl (xflds_prime, p),
                        and (datum (p, x, ty),
                          "true"))))));
  e.ty = ty;
}

{- Fld_Decls -}

aspect production fld_decls_list
top::FldDecls ::= d::FldDecl ds::FldDecls
{
  propagate s;
  top.const = and (d.const, ds.const);
}

aspect production fld_decls_empty
top::FldDecls ::=
{
  top.const = "true";
}

{- Fld_Decl -}

aspect production fld_decl
top::FldDecl ::= x::String tyann::Type
{
  propagate s;
  local ty :: String = exists ("ty");
  local s_fld :: String = exists ("s_fld");
  top.const = and (tyann.const,
                and (new_scope_datum (s_fld, x, ty),
                  edge (top.s, "`VAR", s_fld)));
  tyann.ty = ty;
}

{- Arg_Decl -}

aspect production arg_decl
top::ArgDecl ::= x::String tyann::Type
{
  propagate s;
  local ty :: String = exists ("ty");
  local s_fld :: String = exists ("s_fld");
  top.const = and (tyann.const,
                and (new_scope_datum (s_fld, x, ty),
                  edge (top.s, "`VAR", s_fld)));
  tyann.ty = ty;
}

{- Type -}

aspect production type_int
top::Type ::= 
{
  top.const = eq (top.ty, "INT()");
}

aspect production type_bool
top::Type ::=
{
  top.const = eq (top.ty, "BOOL()");
}

aspect production type_arrow
top::Type ::= tyann1::Type tyann2::Type
{
  propagate s;
  local ty1 :: String = exists ("ty1");
  local ty2 :: String = exists ("ty2");
  top.const = and (tyann1.const,
                and (tyann2.const,
                  eq (top.ty, "FUN(" ++ ty1 ++ ", " ++ ty2 ++ ")")));
  tyann1.ty = ty1;
  tyann2.ty = ty2;
}

aspect production type_rec
top::Type ::= r::TypeRef
{
  propagate s;
  local p :: String = exists ("p");
  local x :: String = exists ("x");
  --local ty :: String = exists ("ty");
  top.const = and (r.const,
                datum (p, x, top.ty));
  r.p = p;
}

{- Mod_Ref -}

aspect production mod_ref_single
top::ModRef ::= x::String
{
  local mods :: String = exists ("mods");
  local xmods :: String = exists ("xmods");
  local xmods_prime :: String = exists ("xmods'");
  top.const = and (query (top.s, "`LEX*`IMP? `MOD", mods),
                and (filt (mods, "((x', _) where x' == " ++ x ++ ")", xmods),
                  and (min_refs (xmods, xmods_prime),
                    onl (xmods_prime, top.p))));
}

aspect production mod_ref_dot
top::ModRef ::= r::ModRef x::String
{
  local p_mod :: String = exists ("p_mod");
  local s_mod :: String = exists ("s_mod");
  local mods :: String = exists ("mods");
  local xmods :: String = exists ("xmods");
  top.const = and (r.const,
                and (tgt (p_mod, s_mod),
                  and (query (s_mod, "`MOD", mods),
                    and (filt (mods, "((x', _) where x' == " ++ x ++ ")", xmods),
                      onl (xmods, top.p)))));
  r.s = top.s;
  r.p = p_mod;
}

{- Type_Ref -}

aspect production type_ref_single
top::TypeRef ::= x::String
{
  local recs :: String = exists ("recs");
  local xrecs :: String = exists ("xrecs");
  local xrecs_prime :: String = exists ("xrecs'");
  top.const = and (query (top.s, "`LEX*`IMP? `REC", recs),
                and (filt (recs, "((x', _) where x' == " ++ x ++ ")", xrecs),
                  and (min_refs (xrecs, xrecs_prime),
                    onl (xrecs_prime, top.p))));
}

aspect production type_ref_dot
top::TypeRef ::= r::ModRef x::String
{
  local p_mod :: String = exists ("p_mod");
  local s_mod :: String = exists ("s_mod");
  local recs :: String = exists ("recs");
  local xrecs :: String = exists ("xrecs");
  top.const = and (r.const,
                and (tgt (p_mod, s_mod),
                  and (query (s_mod, "`REC", recs),
                    and (filt (recs, "((x', _) where x' == " ++ x ++ ")", xrecs),
                      onl (xrecs, top.p)))));
  r.s = top.s;
  r.p = p_mod;
}

{- Var_Ref -}

aspect production var_ref_single
top::VarRef ::= x::String
{
  local vars :: String = exists ("vars");
  local xvars :: String = exists ("xvars");
  local xvars_prime :: String = exists ("xvars'");
  top.const = and (query (top.s, "`LEX*(`EXT*|`IMP?) `VAR", vars),
                and (filt (vars, "((x', _) where x' == " ++ x ++ ")", xvars),
                  and (min_refs (xvars, xvars_prime),
                    onl (xvars_prime, top.p))));
}

aspect production var_ref_dot
top::VarRef ::= r::ModRef x::String
{
  local p_mod :: String = exists ("p_mod");
  local s_mod :: String = exists ("s_mod");
  local vars :: String = exists ("vars");
  local xvars :: String = exists ("xvars");
  top.const = and (r.const,
                and (tgt (p_mod, s_mod),
                  and (query (s_mod, "`VAR", vars),
                    and (filt (vars, "((x', _) where x' == " ++ x ++ ")", xvars),
                      onl (xvars, top.p)))));
  r.s = top.s;
  r.p = p_mod;
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

function eq
String ::= t1::String t2::String
{
  return t1 ++ " == " ++ t2;
}

function query
String ::= scope::String regex::String name::String
{
  return "query " ++ scope ++ " " ++ regex ++ " as " ++ name;
}

function filt
String ::= flds::String pred::String xflds::String
{
  return "filter " ++ flds ++ " " ++ pred ++ " " ++ xflds;
}

function onl
String ::= lst::String x::String
{
  return "only(" ++ lst ++ ", " ++ x ++ ")";
}

function tgt
String ::= p::String s::String
{
  return "tgt(" ++ p ++ ", " ++ s ++ ")";
}