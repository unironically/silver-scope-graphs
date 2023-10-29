grammar simpleseqlet:scopegraphs;

aspect production mk_scope_generic
top::Scope ::= 
  datum::Maybe<Datum>
  mod_edges :: [Scope]
  var_edges :: [Scope]
  rec_edges :: [Scope]
  ext_edges :: [Scope]
  imp_edges :: [Scope]
  lex_edges :: [Scope]
  fld_edges :: [Scope]
{}

aspect production mk_scope
top::Scope ::= 
  mod_edges :: [Scope]
  var_edges :: [Scope]
  rec_edges :: [Scope]
  ext_edges :: [Scope]
  imp_edges :: [Scope]
  lex_edges :: [Scope]
  fld_edges :: [Scope]
{}

aspect production mk_scope_datum
top::Scope ::= 
  datum::Datum
  mod_edges :: [Scope]
  var_edges :: [Scope]
  rec_edges :: [Scope]
  ext_edges :: [Scope]
  imp_edges :: [Scope]
  lex_edges :: [Scope]
  fld_edges :: [Scope]
{}