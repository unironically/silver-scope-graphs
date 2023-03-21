grammar scope_tree:ast;

{-====================-}

inherited attribute scope_id :: Integer 
  occurs on Scope<d r>, Scopes<d r>, Refs<d r>, Ref<d r>, Decls<d r>, Decl<d r>;
synthesized attribute last_id :: Integer 
  occurs on Ref<d r>, Scope<d r>, Scopes<d r>;

synthesized attribute id :: String 
  occurs on Scope<d r>, Ref<d r>, Decl<d r>;

synthesized attribute str :: String 
  occurs on Ref<d r>, Decl<d r>;
synthesized attribute substr :: String 
  occurs on Ref<d r>, Decl<d r>;

{-====================-}

aspect production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  root.scope_id = 0;
}

{-====================-}

aspect production mk_scope
s::Scope<d r> ::= 
  decls::Decls<d r> 
  refs::Refs<d r> 
  children::Scopes<d r>
{
  children.scope_id = 0;
  decls.scope_id = children.last_id;
  refs.scope_id = s.scope_id;
  s.last_id = 0;
  s.id = scope_id (s.parent, s.scope_id);
}

aspect production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{
  ref.scope_id = s.scope_id;
  s.last_id = max (s.scope_id, ref.last_id);
  s.id = scope_id (s.parent, s.scope_id);
}


aspect production mk_decl
d::Decl<d r> ::= 
  _
{
  local parts::[String] = explode ("_", d.name);
  d.id = head(parts);
  d.substr = head(tail(parts));
  d.str = d.name;
}


aspect production mk_decl_assoc
d::Decl<d r> ::= 
  _
  module::Scope<d r> 
{
  local parts::[String] = explode ("_", d.name);
  d.id = head(parts);
  d.substr = head(tail(parts));
  d.str = d.name;
  module.scope_id = d.scope_id;
}


aspect production mk_ref
r::Ref<d r> ::= 
  _
{
  local parts::[String] = explode ("_", r.name);
  r.id = head(parts);
  r.substr = head(tail(parts));
  r.str = r.name;
  r.last_id = 0;
}

aspect production mk_imp
r::Ref<d r> ::= 
  _
{
  local parts::[String] = explode ("_", r.name);
  r.id = head(parts);
  r.substr = head(tail(parts));
  r.str = r.name;
  r.last_id = 0;
}

aspect production mk_ref_qid
r::Ref<d r> ::= 
  _
  qid_scope::Scope<d r> 
{
  local parts::[String] = explode ("_", r.name);
  r.id = head(parts);
  r.substr = head(tail(parts));
  r.str = r.name;
  r.last_id = qid_scope.last_id;
  qid_scope.scope_id = r.scope_id;
}

{-====================-}

aspect production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{
  s.scope_id = ss.scope_id + 1;
  st.scope_id = ss.scope_id + 1;
  ss.last_id = 1 + st.last_id;
}

aspect production scope_nil
ss::Scopes<d r> ::=
{
  ss.last_id = 0;
}

aspect production decl_cons
ds::Decls<d r> ::= 
  d::Decl<d r> 
  dt::Decls<d r>
{
  d.scope_id = ds.scope_id + 1;
  dt.scope_id = ds.scope_id + case d of mk_decl_assoc (_, _) -> 1 | _ -> 0 end;
}

aspect production decl_nil
ds::Decls<d r> ::= 
{}

aspect production ref_cons
rs::Refs<d r> ::= 
  r::Ref<d r> 
  rt::Refs<d r>
{
  r.scope_id = rs.scope_id;
  rt.scope_id = r.last_id;
}

aspect production ref_nil
rs::Refs<d r> ::= 
{}

{-====================-}

function scope_id
String ::= 
  par::Maybe<Decorated Scope<d r>> 
  id::Integer
{
  return
    case par of
      | nothing () -> toString (id)
      | just (p) -> p.id ++ "." ++ toString (id)
    end;
}