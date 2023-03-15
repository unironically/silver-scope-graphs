grammar scope_tree:ast;

{-====================-}

inherited attribute scope_id :: Integer 
  occurs on Scope<a>, Scopes<a>, Refs<a>, Ref<a>, Decls<a>, Decl<a>;
synthesized attribute last_id :: Integer 
  occurs on Ref<a>, Scope<a>, Scopes<a>;

synthesized attribute id :: String 
  occurs on Scope<a>, Ref<a>, Decl<a>;

synthesized attribute str :: String 
  occurs on Ref<a>, Decl<a>;
synthesized attribute substr :: String 
  occurs on Ref<a>, Decl<a>;

{-====================-}

aspect production mk_graph
g::Graph<a> ::= 
  root::Scope<a>
{
  root.scope_id = 0;
}

{-====================-}

aspect production mk_scope
s::Scope<a> ::= 
  decls::Decls<a> 
  refs::Refs<a> 
  children::Scopes<a>
{
  children.scope_id = 0;
  decls.scope_id = children.last_id;
  refs.scope_id = s.scope_id;
  s.last_id = 0;
  s.id = scope_id (s.parent, s.scope_id);
}

aspect production mk_scope_qid
s::Scope<a> ::= 
  ref::Ref<a>
{
  ref.scope_id = s.scope_id;
  s.last_id = max (s.scope_id, ref.last_id);
  s.id = scope_id (s.parent, s.scope_id);
}


aspect production mk_decl
d::Decl<a> ::= 
  id::String 
  _
{
  local parts::[String] = explode ("_", id);
  d.id = head(parts);
  d.substr = head(tail(parts));
  d.str = id;
}


aspect production mk_decl_assoc
d::Decl<a> ::= 
  id::String 
  s::Scope<a> 
  _
{
  local parts::[String] = explode ("_", id);
  d.id = head(parts);
  d.substr = head(tail(parts));
  d.str = id;
  s.scope_id = d.scope_id;
}


aspect production mk_ref
r::Ref<a> ::= 
  id::String 
  _
{
  local parts::[String] = explode ("_", id);
  r.id = head(parts);
  r.substr = head(tail(parts));
  r.str = id;
  r.last_id = 0;
}

aspect production mk_imp
r::Ref<a> ::= 
  id::String 
  _
{
  local parts::[String] = explode ("_", id);
  r.id = head(parts);
  r.substr = head(tail(parts));
  r.str = id;
  r.last_id = 0;
}

aspect production mk_ref_qid
r::Ref<a> ::= 
  id::String 
  s::Scope<a> 
  _
{
  local parts::[String] = explode ("_", id);
  r.id = head(parts);
  r.substr = head(tail(parts));
  r.str = id;
  r.last_id = s.last_id;
  s.scope_id = r.scope_id;
}

{-====================-}

aspect production scope_cons
ss::Scopes<a> ::= 
  s::Scope<a> 
  st::Scopes<a>
{
  s.scope_id = ss.scope_id + 1;
  st.scope_id = ss.scope_id + 1;
  ss.last_id = 1 + st.last_id;
}

aspect production scope_nil
ss::Scopes<a> ::=
{
  ss.last_id = 0;
}

aspect production decl_cons
ds::Decls<a> ::= 
  d::Decl<a> 
  dt::Decls<a>
{
  d.scope_id = ds.scope_id + 1;
  dt.scope_id = ds.scope_id + case d of mk_decl_assoc (_, _, _) -> 1 | _ -> 0 end;
}

aspect production decl_nil
ds::Decls<a> ::= 
{}

aspect production ref_cons
rs::Refs<a> ::= 
  r::Ref<a> 
  rt::Refs<a>
{
  r.scope_id = rs.scope_id;
  rt.scope_id = r.last_id;
}

aspect production ref_nil
rs::Refs<a> ::= 
{}

{-====================-}

function scope_id
String ::= 
  par::Maybe<Decorated Scope<a>> 
  id::Integer
{
  return
    case par of
      | nothing () -> toString (id)
      | just (p) -> p.id ++ "." ++ toString (id)
    end;
}