grammar simpleseqlet:scopegraphs;

aspect production mk_scope_generic
top::Scope ::= 
  datum::Maybe<Datum>
  mod_edges :: [Decorated Scope]
  var_edges :: [Decorated Scope]
  rec_edges :: [Decorated Scope]
  ext_edges :: [Decorated Scope]
  imp_edges :: [Decorated Scope]
  lex_edges :: [Decorated Scope]
  fld_edges :: [Decorated Scope]
{}

aspect production mk_scope
top::Scope ::= 
  mod_edges :: [Decorated Scope]
  var_edges :: [Decorated Scope]
  rec_edges :: [Decorated Scope]
  ext_edges :: [Decorated Scope]
  imp_edges :: [Decorated Scope]
  lex_edges :: [Decorated Scope]
  fld_edges :: [Decorated Scope]
{}

aspect production mk_scope_datum
top::Scope ::= 
  datum::Datum
  mod_edges :: [Decorated Scope]
  var_edges :: [Decorated Scope]
  rec_edges :: [Decorated Scope]
  ext_edges :: [Decorated Scope]
  imp_edges :: [Decorated Scope]
  lex_edges :: [Decorated Scope]
  fld_edges :: [Decorated Scope]
{}