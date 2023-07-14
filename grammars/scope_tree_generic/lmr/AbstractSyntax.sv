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

inherited attribute scope :: Scope occurs on Decls, Decl, Super, TypeRef, 
  SeqBinds, SeqBind, Expr, ArgDecl;
inherited attribute s_rec :: Scope occurs on Super;
inherited attribute s_def :: Scope occurs on SeqBinds, SeqBind;

synthesized attribute mod_edges :: Edges occurs on Decls, Decl, Super, 
  FldDecls, SeqBinds, SeqBind, Expr, ArgDecl;
synthesized attribute var_edges :: Edges occurs on Decls, Decl, Super, 
  FldDecls, SeqBinds, SeqBind, Expr, ArgDecl;
synthesized attribute rec_edges :: Edges occurs on Decls, Decl, Super, 
  FldDecls, SeqBinds, SeqBind, Expr, ArgDecl;
synthesized attribute ext_edges :: Edges occurs on Decls, Decl, Super, 
  FldDecls, SeqBinds, SeqBind, Expr, ArgDecl;
synthesized attribute imp_edges :: Edges occurs on Decls, Decl, Super, 
  FldDecls, SeqBinds, SeqBind, Expr, ArgDecl;
synthesized attribute lex_edges :: Edges occurs on Decls, Decl, Super, 
  FldDecls, SeqBinds, SeqBind, Expr, ArgDecl;

synthesized attribute ty :: LMR_Type occurs on Expr, ArgDecl;

synthesized attribute path :: Path occurs on ModRef, TypeRef, VarRef;

{- Program -}

abstract production program
top::Program ::= h::String ds::Decls
{
  local s :: Scope = mk_scope (ds.mod_edges, ds.var_edges);
  ds.scope = s;
}

{- Decls -}

abstract production decls_list
top::Decls ::= d::Decl ds::Decls
{ propagate scope; }

abstract production decls_empty
top::Decls ::= 
{}

{- Decl -}

abstract production decl_module
top::Decl ::= x::String ds::Decls
{
  local s_mod :: Scope = 
    mk_scope_datum (
      (x, datum_scope (s_mod)), 
      edges_cons (mod_edge, ds.mod_edges), 
      ds.var_edges
    );
  local mod_edge :: Edge = mk_edge (mod_lab, s_mod);
  local lex_edge :: Edge = mk_edge (lex_lab, top.scope);
  ds.scope = s_mod;
  top.lex_edges = edges_single (lex_edge);
}

abstract production decl_import
top::Decl ::= r::ModRef
{
  propagate scope;
  local imp_edge :: Edge = mk_edge (imp_lab, r.path.dst);
  top.imp_edges = edges_single (imp_edge);
}

abstract production decl_def
top::Decl ::= b::ParBind
{ propagate scope; }

abstract production decl_rec
top::Decl ::= x::String sup::Super ds::FldDecls
{
  propagate scope;
  local s_rec :: Scope = 
    mk_scope_datum ((x, datum_type (rec_type (s_rec))), sup.mod_edges, sup.var_edges);
  local rec_edge :: Edge = mk_edge (rec_lab, s_rec);
  sup.s_rec = s_rec;
}

{- Super -}

abstract production super_none
top::Super ::=
{}

abstract production super_some
top::Super ::= r::TypeRef
{
  propagate scope;
  local ext_edge :: Edge = mk_edge (ext_lab, r.path.dst);
  top.mod_edges = edges_none ();
  top.var_edges = edges_none ();
  top.rec_edges = edges_none ();
  top.ext_edges = edges_single (ext_edge);
  top.imp_edges = edges_none ();
  top.lex_edges = edges_none ();
}

{- Seq_Binds -}

abstract production seq_binds_empty
top::SeqBinds ::=
{
  local lex_edge :: Edge = mk_edge (lex_lab, top.scope);
  top.lex_edges = edges_single (lex_edge);
}

abstract production seq_binds_single
top::SeqBinds ::= b::SeqBind
{ 
  propagate scope, s_def;
  local lex_edge :: Edge = mk_edge (lex_lab, top.scope);
  top.lex_edges = edges_single (lex_edge);
}

abstract production seq_binds_list
top::SeqBinds ::= b::SeqBind bs::SeqBinds
{
  local s_def_prime :: Scope = 
    mk_scope (b.mod_edges, b.var_edges);
  local lex_edge :: Edge = -- todo: add to s_def_prime edges above
    mk_edge (lex_lab, top.scope);
  b.scope = top.scope;
  b.s_def = s_def_prime;
  bs.scope = s_def_prime;
  bs.s_def = top.s_def;
}

{- Seq_Bind -}

abstract production seq_defbind
top::SeqBind ::= x::String e::Expr
{
  local s_var :: Scope = 
    mk_scope_datum ((x, datum_type (e.ty)), edges_none (), edges_single (var_edge));
  local var_edge :: Edge = mk_edge (var_lab, s_var);
  top.mod_edges = e.mod_edges;
  top.var_edges = edges_cons (var_edge, e.var_edges);
  top.rec_edges = e.rec_edges;
  top.ext_edges = e.ext_edges;
  top.imp_edges = e.imp_edges;
  top.lex_edges = e.lex_edges;
  e.scope = top.scope;
}

abstract production seq_defbind_typed
top::SeqBind ::= x::String tyann::Type e::Expr
{
  local s_var :: Scope = 
    mk_scope_datum ((x, datum_type (e.ty)), edges_none (), edges_single (var_edge));
  local var_edge :: Edge = mk_edge (var_lab, s_var);
  -- type equality check between tyann and e.ty here --
  top.mod_edges = e.mod_edges;
  top.var_edges = edges_cons (var_edge, e.var_edges);
  top.rec_edges = e.rec_edges;
  top.ext_edges = e.ext_edges;
  top.imp_edges = e.imp_edges;
  top.lex_edges = e.lex_edges;
  e.scope = top.scope;
}

{- Par_Binds -}

abstract production par_binds_list
top::ParBinds ::= b::ParBind bs::ParBinds
{}

abstract production par_binds_empty
top::ParBinds ::=
{ propagate scope; }

{- Par_Bind -}

abstract production par_defbind
top::ParBind ::= x::String e::Expr
{
  local s_var :: Scope = 
    mk_scope_datum ((x, datum_type (e.ty)), edges_none (), edges_none ());
  local var_edge :: Edge = mk_edge (var_lab, s_var);
  -- todo
}

abstract production par_defbind_typed
top::ParBind ::= x::String tyann::Type e::Expr
{
  local s_var :: Scope = 
    mk_scope_datum ((x, datum_type (e.ty)), edges_none (), edges_none ());
  local var_edge :: Edge = mk_edge (var_lab, s_var);
  -- todo
}

{- Expr -}

abstract production expr_int
top::Expr ::= i::Integer
{
  top.ty = int_type ();
}

abstract production expr_bool
top::Expr ::= b::Boolean
{
  top.ty = bool_type ();
}

abstract production expr_var
top::Expr ::= r::VarRef
{
  propagate scope;
  -- datum (p, (x, ty))
}

abstract production expr_add
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = int
  top.ty = int_type ();
}

abstract production expr_sub
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = int
  top.ty = int_type ();
}

abstract production expr_mul
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = int
  top.ty = int_type ();
}

abstract production expr_div
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = int
  top.ty = int_type ();
}

abstract production expr_and
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = bool
  top.ty = bool_type ();
}

abstract production expr_or
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = bool
  top.ty = bool_type ();
}

abstract production expr_eq
top::Expr ::= e1::Expr e2::Expr
{
  -- e1.ty = e2.ty = t
  top.ty = e1.ty;
}

abstract production expr_app
top::Expr ::= e1::Expr e2::Expr
{
  -- todo
}

abstract production expr_if
top::Expr ::= e1::Expr e2::Expr e3::Expr
{
  -- e1.ty = bool, e2.ty = e3.ty
  top.ty = e2.ty;
  -- what does the `true` constraint mean for this implementation?
}

abstract production expr_fun
top::Expr ::= d::ArgDecl e::Expr
{
  local s_fun :: Scope = 
    mk_scope (edges_concat (d.mod_edges, e.mod_edges), 
              edges_concat (d.var_edges, e.var_edges));
  local lex_edge :: Edge = mk_edge (lex_lab, top.scope); -- add this to lex edges of s_fun
  d.scope = s_fun;
  e.scope = s_fun;
  top.ty = fun_type (d.ty, e.ty);
}

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