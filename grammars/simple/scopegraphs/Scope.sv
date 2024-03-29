grammar simple:scopegraphs;

imports simple;


nonterminal Scope;
synthesized attribute id :: Integer occurs on Scope;
synthesized attribute mod_edges :: [Scope] occurs on Scope;
synthesized attribute var_edges :: [Scope] occurs on Scope;
synthesized attribute rec_edges :: [Scope] occurs on Scope;
synthesized attribute ext_edges :: [Scope] occurs on Scope;
synthesized attribute imp_edges :: [Scope] occurs on Scope;
synthesized attribute lex_edges :: [Scope] occurs on Scope;
synthesized attribute fld_edges :: [Scope] occurs on Scope;
synthesized attribute datum :: Maybe<Datum> occurs on Scope;

abstract production mk_scope_generic
top::Scope ::= 
  datum::Maybe<Datum>
  mod_edges :: [Scope]
  var_edges :: [Scope]
  rec_edges :: [Scope]
  ext_edges :: [Scope]
  imp_edges :: [Scope]
  lex_edges :: [Scope]
  fld_edges :: [Scope]
{
  top.id = genInt ();
  top.mod_edges = mod_edges;
  top.var_edges = var_edges;
  top.rec_edges = rec_edges;
  top.ext_edges = ext_edges;
  top.imp_edges = imp_edges;
  top.lex_edges = lex_edges;
  top.fld_edges = fld_edges;
  top.datum = datum;
}

abstract production mk_scope
top::Scope ::= 
  mod_edges :: [Scope]
  var_edges :: [Scope]
  rec_edges :: [Scope]
  ext_edges :: [Scope]
  imp_edges :: [Scope]
  lex_edges :: [Scope]
  fld_edges :: [Scope]
{ forwards to mk_scope_generic (nothing(), mod_edges, var_edges, rec_edges, 
                                ext_edges, imp_edges, lex_edges, fld_edges); }

abstract production mk_scope_datum
top::Scope ::= 
  datum::Datum
  mod_edges :: [Scope]
  var_edges :: [Scope]
  rec_edges :: [Scope]
  ext_edges :: [Scope]
  imp_edges :: [Scope]
  lex_edges :: [Scope]
  fld_edges :: [Scope]
{ forwards to mk_scope_generic (just (datum), mod_edges, var_edges, rec_edges, 
                                ext_edges, imp_edges, lex_edges, fld_edges); }

abstract production mk_scope_decl
top::Scope ::=
  datum::Datum
{ forwards to mk_scope_generic (just (datum), [], [], [], [], [], [], []); }

nonterminal Datum;
type Datum_Id = String;

abstract production datum_scope
top::Datum ::= str::Datum_Id s::Scope
{}

abstract production datum_type
top::Datum ::= str::Datum_Id t::Type res::Either<Boolean Integer>
{}

function same_id_check
Boolean ::= x1::String d::Datum {
  return case d of
           datum_type (x2, t, _) -> x1 == x2
         | _ -> false
         end;
}

{-
The productions for Datum should be defined in the object language.
The productions for Identifier should be defined in the object language.
-}