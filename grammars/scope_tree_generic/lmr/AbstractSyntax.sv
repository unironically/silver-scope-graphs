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

inherited attribute s::Scope;
inherited attribute s_rec::Scope;
inherited attribute s_def::Scope;

synthesized attribute p::Path;
synthesized attribute ty::LMR_Type;

monoid attribute var_edges::[Scope] with [], ++;

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

attribute s occurs on SeqBinds;
attribute s_def occurs on SeqBinds;
attribute lex_edges occurs on SeqBinds;
attribute var_edges occurs on SeqBinds;

abstract production seq_binds_empty
top::SeqBinds ::=
{

}

abstract production seq_binds_single
top::SeqBinds ::= b::SeqBind
{}

abstract production seq_binds_list
top::SeqBinds ::= b::SeqBind bs::SeqBinds
{}

{- Seq_Bind -}

attribute s occurs on SeqBind;
attribute s_def occurs on SeqBind;
attribute var_edges occurs on SeqBind;

abstract production seq_defbind
top::SeqBind ::= x::String e::Expr
{

}

abstract production seq_defbind_typed
top::SeqBind ::= x::String tyann::Type e::Expr
{

}

{- Par_Binds -}

attribute s occurs on ParBinds;
attribute s_def occurs on ParBinds;
attribute s_var_edges occurs on ParBinds;
attribute var_edges occurs on ParBinds;

abstract production par_binds_list
top::ParBinds ::= b::ParBind bs::ParBinds
{ propagate s, s_def, s_var_edges, var_edges; }

abstract production par_binds_empty
top::ParBinds ::=
{ propagate s, s_def, s_var_edges, var_edges; }

{- Par_Bind -}

attribute s occurs on ParBind;
attribute s_def occurs on ParBind;
monoid attribute s_var_edges::[Scope] with [],++ occurs on ParBind;
attribute var_edges occurs on ParBind;

abstract production par_defbind
top::ParBind ::= x::String e::Expr
{ propagate var_edges;
  local s_var::Scope = mk_scope_decl (datum_type (x, e.ty));
  top.s_var_edges := [s_var];
  e.s = top.s;
}

abstract production par_defbind_typed
top::ParBind ::= x::String tyann::Type e::Expr
{ propagate var_edges;
  local s_var::Scope = mk_scope_decl (datum_type (x, e.ty));
  top.s_var_edges := [s_var];
  e.s = top.s;
  {- TODO: error checking that e.ty = tyann.ty -}
}

{- Expr -}

attribute s occurs on Expr;
attribute ty occurs on Expr;
attribute var_edges occurs on Expr;

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
  local s_let::Scope = mk_scope ([], [], [], [], [], [], []);
  bs.s = top.s;
  bs.s_def = s_let;
  e.s = s_let;
  top.ty = e.ty;
  top.var_edges <- bs.var_edges;
}

abstract production expr_letrec
top::Expr ::= bs::ParBinds e::Expr
{
  local s_let::Scope = mk_scope (e.var_edges ++ bs.s_var_edges, [], [], [], [], [top.s], []);
  bs.s = s_let;
  bs.s_def = s_let;
  e.s = s_let;
  top.ty = e.ty;
  top.var_edges := [];
}

abstract production expr_letpar
top::Expr ::= bs::ParBinds e::Expr
{
  --local s_let::Scope = mk_scope (e.var_edges ++ bs.s_def_var_edges, [], [], [], [], [top.s], []);
  --bs.s = top.s;
  --bs.s_def = s_let;
  --e.s = s_let;
  --top.ty = e.ty;
  --top.var_edges <- bs.s_var_edges;
}

abstract production expr_new
top::Expr ::= r::TypeRef bs::FldBinds
{
  r.s = top.s;
  local p::Path = r.p;
  local s_rec::Scope = case p.tgt.datum of 
                         just(datum_scope (id, s_rec)) -> s_rec
                       | _ -> mk_scope ([], [], [], [], [], [], []) {- TODO: error checking -}
                       end;
  bs.s = top.s;
  bs.s_rec = s_rec;

  top.ty = rec_type (s_rec);
  top.var_edges <- bs.var_edges;
}

abstract production expr_fld_access
top::Expr ::= e::Expr x::String
{
  e.s = top.s;
  local s_rec::Scope = case e.ty of
                         rec_type (s_rec) -> s_rec
                       | _ -> mk_scope ([], [], [], [], [], [], []) {- TODO: error checking -}
                       end;
  local q::Query = mk_query (concatenate (
                               star (single (ext_lab)),
                               single (fld_lab)
                             ),
                             s_rec,
                             same_id_check (x, _));

  local p::Path = head(q.results);
  top.ty = case p.tgt.datum of 
             just(datum_type (s, t)) -> t
           | _ -> err_ty ()
           end;

  top.var_edges <- e.var_edges;
}

abstract production expr_with
top::Expr ::= e1::Expr e2::Expr
{
  e1.s = top.s;
  local s_rec::Scope = case e1.ty of
                         rec_type (s_rec) -> s_rec
                       | _ -> mk_scope ([], [], [], [], [], [], []) {- TODO: error checking -}
                       end;
  local s_with::Scope = mk_scope ([], [], [], [s_rec], [], [], []); {- TODO: when know what edges Expr can synth -}

  e2.s = s_with;
  top.ty = e2.ty;
  top.var_edges <- e2.var_edges;
}

{- Fld_Binds -}

attribute s occurs on FldBinds;
attribute s_rec occurs on FldBinds;
attribute var_edges occurs on FldBinds;

abstract production fld_binds_list
top::FldBinds ::= b::FldBind bs::FldBinds
{ propagate s, s_rec, var_edges; }

abstract production fld_binds_empty
top::FldBinds ::=
{ propagate s, s_rec, var_edges; }

{- FldBind -}

attribute s occurs on FldBind;
attribute s_rec occurs on FldBind;
attribute var_edges occurs on FldBind;

abstract production fld_bind
top::FldBind ::= x::String e::Expr
{
  propagate var_edges;
  e.s = top.s;
  local q::Query = mk_query (concatenate (
                               star (single (ext_lab)),
                               single (fld_lab)
                             ),
                             top.s_rec,
                             same_id_check (x, _));
  {- Check here that e.ty == q.results.tgt.datum's ty -}
}

{- Fld_Decls -}

attribute s occurs on FldDecls;
attribute var_edges occurs on FldDecls;

abstract production fld_decls_list
top::FldDecls ::= d::FldDecl ds::FldDecls
{ propagate s, var_edges; }

abstract production fld_decls_empty
top::FldDecls ::=
{ propagate s, var_edges; }

{- FldDecl -}

attribute s occurs on FldDecl;
attribute var_edges occurs on FldDecl;

abstract production fld_decl
top::FldDecl ::= x::String tyann::Type
{
  tyann.s = top.s;
  local s_var::Scope = mk_scope_decl (datum_type (x, tyann.ty));
  top.var_edges := [s_var];
}

{- Arg_Decl -}

attribute s occurs on ArgDecl;
attribute ty occurs on ArgDecl;
attribute var_edges occurs on ArgDecl;

abstract production arg_decl
top::ArgDecl ::= x::String tyann::Type
{
  tyann.s = top.s;
  top.ty = tyann.ty;
  local s_var::Scope = mk_scope_decl (datum_type (x, top.ty));
  top.var_edges := [s_var];
}

{- Type -}

attribute s occurs on Type;
attribute ty occurs on Type;

abstract production type_int
top::Type ::= 
{
  top.ty = int_type ();
}

abstract production type_bool
top::Type ::=
{
  top.ty = bool_type ();
}

abstract production type_arrow
top::Type ::= tyann1::Type tyann2::Type
{
  top.ty = fun_type (tyann1.ty, tyann2.ty);
}

abstract production type_rec
top::Type ::= r::TypeRef
{
  r.s = top.s;
  top.ty = case r.p.tgt.datum of
             just(datum_type (s, t)) -> t
           | _ -> err_ty ()
           end;
}

{- Mod_Ref -}

attribute s occurs on ModRef;
attribute p occurs on ModRef;

abstract production mod_ref_single
top::ModRef ::= x::String
{
  local q :: Query = mk_query ( 
                                concatenate (
                                  star (single (lex_lab)),
                                  concatenate (
                                   maybe (single (imp_lab)),
                                   single (mod_lab)
                                  )
                                ),
                                top.s,
                                same_id_check (x, _)
                              );
  top.p = head(q.results);
}

abstract production mod_ref_dot
top::ModRef ::= r::ModRef x::String
{
  r.s = top.s;
  local p_mod :: Path = r.p;
  local s_mod :: Scope = p_mod.tgt;
  local q :: Query = mk_query (single(mod_lab),
                               s_mod,
                               same_id_check (x, _)
                              );
  top.p = head(q.results);
}

{- Type_Ref -}

attribute s occurs on TypeRef;
attribute p occurs on TypeRef;

abstract production type_ref_single
top::TypeRef ::= x::String
{
  local q :: Query = mk_query ( 
                                concatenate (
                                  star (single (lex_lab)),
                                  concatenate (
                                   maybe (single (imp_lab)),
                                   single (rec_lab)
                                  )
                                ),
                                top.s,
                                same_id_check (x, _)
                              );
  top.p = head(q.results);
}

abstract production type_ref_dot
top::TypeRef ::= r::ModRef x::String
{
  r.s = top.s;
  local p_mod :: Path = r.p;
  local s_mod :: Scope = p_mod.tgt;
  local q :: Query = mk_query (single(rec_lab),
                               s_mod,
                               same_id_check (x, _)
                              );
  top.p = head(q.results);
}

{- Var_Ref -}

attribute s occurs on VarRef;
attribute p occurs on VarRef;

abstract production var_ref_single
top::VarRef ::= x::String
{
  local q :: Query = mk_query (concatenate (
                                  star (single(lex_lab)),
                                  alternate (
                                    star (single(ext_lab)),
                                    maybe (single(imp_lab)))),
                               top.s,
                               same_id_check (x, _));
  top.p = head(q.results);
}

abstract production var_ref_dot
top::VarRef ::= r::ModRef x::String
{
  r.s = top.s;
  local p_mod :: Path = r.p;
  local s_mod :: Scope = p_mod.tgt;
  local q :: Query = mk_query (single(var_lab),
                               s_mod,
                               same_id_check (x, _)
                              );
  top.p = head(q.results);
}