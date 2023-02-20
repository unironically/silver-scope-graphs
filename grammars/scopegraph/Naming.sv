grammar scopegraph;

inherited attribute id :: Integer occurs on Scope, Scopes;
synthesized attribute name :: String occurs on Scope, Ref, Decl;

synthesized attribute str :: String occurs on Ref, Decl;
synthesized attribute substr :: String occurs on Ref, Decl;

synthesized attribute assocDeclName :: (Integer ::= String) occurs on Scope, Scopes;

aspect production mk_graph 
g::Graph ::= children::Scopes
{
  children.id = 0;
}

aspect production mk_scope_real
s::Scope ::= decls::Decls refs::Refs imps::Imps children::Scopes assoc_decl::Maybe<Decl>
{
  s.name = 
    case s.scope_parent of
      | nothing () -> toString (s.id)
      | just (p) -> p.name ++ "." ++ toString (s.id)
    end;
  children.id = 0;

  s.assocDeclName = (\s::String -> children.assocDeclName (s));
}

aspect production mk_decl
d::Decl ::= id::String
{
  local parts::[String] = explode ("_", id);
  d.name = head(parts);
  d.substr = head(tail(parts));
  d.str = id;
}

aspect production mk_decl_assoc
d::Decl ::= id::String s::Scope
{
  local parts::[String] = explode ("_", id);
  d.name = head(parts);
  d.substr = head(tail(parts));
  d.str = id;
  
  s.id = d.parent.assocDeclName(id);
}

aspect production mk_ref
r::Ref ::= id::String
{
  local parts::[String] = explode ("_", id);
  r.name = head(parts);
  r.substr = head(tail(parts));
  r.str = id;
}

aspect production scope_cons
sl::Scopes ::= s::Scope st::Scopes
{
  s.id = sl.id;
  st.id = sl.id + 1;
  sl.assocDeclName = 
    (\str::String -> case s.assoc_decl of
                       | nothing () -> st.assocDeclName (str)
                       | just(d) -> if d.str == str then s.id else st.assocDeclName (str)
                     end);
}

aspect production scope_nil
sl::Scopes ::=
{
  sl.assocDeclName = (\s::String -> 0);
}
