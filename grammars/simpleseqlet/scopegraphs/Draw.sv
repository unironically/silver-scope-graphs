grammar simpleseqlet:scopegraphs;

synthesized attribute string::String occurs on Scope, Datum;

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
{
  local datumStr::String = case datum of
                             nothing () -> "()"
                           | just(d) -> d.string
                           end;

  local modEdgesStr::String = edgesStr (mod_edges, "MOD", top.id);
  local varEdgesStr::String = edgesStr (var_edges, "VAR", top.id);
  local recEdgesStr::String = edgesStr (rec_edges, "REC", top.id);
  local extEdgesStr::String = edgesStr (ext_edges, "EXT", top.id);
  local impEdgesStr::String = edgesStr (imp_edges, "IMP", top.id);
  local lexEdgesStr::String = edgesStr (lex_edges, "LEX", top.id);
  local fldEdgesStr::String = edgesStr (fld_edges, "FLD", top.id);

  local combinedEdges::String = 
    implode (" ", [modEdgesStr, varEdgesStr, recEdgesStr, 
                   extEdgesStr, impEdgesStr, lexEdgesStr, fldEdgesStr]);

  top.string = "{" ++ 
               toString(top.id) ++ 
               "[label=\"" ++ toString(top.id) ++ " |-> " ++ datumStr ++  "\"]" ++ 
               combinedEdges ++ "}";

}

fun edgesStr String ::= edges::[Decorated Scope] lab::String from::Integer = 
  implode (" ", map ((\s::Decorated Scope -> "edge [label=\"" ++ lab ++ "\"]" ++ toString(from) ++ " -> " ++ toString(s.id)), edges));

{--}


aspect production datum_scope
top::Datum ::= str::Datum_Id s::Decorated Scope
{
  top.string = "";
}

aspect production datum_type
top::Datum ::= str::Datum_Id t::Type
{
  top.string = str ++ " : " ++ t.string;
}