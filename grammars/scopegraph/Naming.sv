grammar scopegraph;

{-====================-}

inherited attribute scope_id :: Integer occurs on Scope_sg, Scopes_sg, Refs_sg, Ref_sg, Decls_sg, Decl_sg;
synthesized attribute last_id :: Integer occurs on Ref_sg, Scope_sg, Scopes_sg;

synthesized attribute name :: String occurs on Scope_sg, Ref_sg, Decl_sg;

synthesized attribute str :: String occurs on Ref_sg, Decl_sg;
synthesized attribute substr :: String occurs on Ref_sg, Decl_sg;

{-====================-}

aspect production mk_graph
g::Graph_sg ::= root::Scope_sg
{
  root.scope_id = 0;
}

{-====================-}

aspect production mk_scope
s::Scope_sg ::= decls::Decls_sg refs::Refs_sg children::Scopes_sg
{
  children.scope_id = 0;
  decls.scope_id = children.last_id;
  refs.scope_id = s.scope_id;
  s.last_id = 0;
  s.name = scope_name (s.parent_sg, s.scope_id);
}

aspect production mk_scope_qid
s::Scope_sg ::= ref::Ref_sg
{
  ref.scope_id = s.scope_id + 1;
  s.last_id = max (s.scope_id, ref.last_id);
  s.name = scope_name (s.parent_sg, s.scope_id);
}


aspect production mk_decl
d::Decl_sg ::= id::String
{
  local parts::[String] = explode ("_", id);
  d.name = head(parts);
  d.substr = head(tail(parts));
  d.str = id;
}


aspect production mk_decl_assoc
d::Decl_sg ::= id::String s::Scope_sg
{
  local parts::[String] = explode ("_", id);
  d.name = head(parts);
  d.substr = head(tail(parts));
  d.str = id;
  s.scope_id = d.scope_id;
}


aspect production mk_ref
r::Ref_sg ::= id::String
{
  local parts::[String] = explode ("_", id);
  r.name = head(parts);
  r.substr = head(tail(parts));
  r.str = id;
  r.last_id = 0;
}

aspect production mk_ref_qid
r::Ref_sg ::= id::String s::Scope_sg
{
  local parts::[String] = explode ("_", id);
  r.name = head(parts);
  r.substr = head(tail(parts));
  r.str = id;
  r.last_id = s.last_id;
  s.scope_id = r.scope_id;
}


{-====================-}

aspect production scope_cons
ss::Scopes_sg ::= s::Scope_sg st::Scopes_sg
{
  s.scope_id = ss.scope_id + 1;
  st.scope_id = ss.scope_id + 1;
  ss.last_id = st.last_id;
}

aspect production scope_nil
ss::Scopes_sg ::=
{
  ss.last_id = ss.scope_id;
}

aspect production decl_cons
ds::Decls_sg ::= d::Decl_sg dt::Decls_sg
{
  d.scope_id = ds.scope_id + 1;
  dt.scope_id = ds.scope_id + case d of mk_decl_assoc (_, _) -> 1 | _ -> 0 end;
}

aspect production decl_nil
ds::Decls_sg ::= 
{
}

aspect production ref_cons
rs::Refs_sg ::= r::Ref_sg rt::Refs_sg
{
  r.scope_id = rs.scope_id + 1;
  rt.scope_id = r.last_id;
}

aspect production ref_nil
rs::Refs_sg ::= 
{
}

{-====================-}

function scope_name
String ::= par::Maybe<Decorated Scope_sg> id::Integer
{
  return
    case par of
      | nothing () -> toString (id)
      | just (p) -> p.name ++ "." ++ toString (id)
    end;
}