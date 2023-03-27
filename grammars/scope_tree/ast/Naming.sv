grammar scope_tree:ast;

{-====================-}

inherited attribute scope_id :: Integer 
  occurs on Scope<d r>, Scopes<d r>, Refs<d r>, Ref<d r>, Decls<d r>, Decl<d r>;

synthesized attribute last_id :: Integer 
  occurs on Ref<d r>, Scope<d r>, Scopes<d r>;

-- `name` is simply the expected string name of a reference
synthesized attribute name :: String
  occurs on Scope<d r>;

attribute name occurs on Ref<d r>, Decl<d r>; -- remove this

synthesized attribute index :: String
  occurs on Ref<d r>, Decl<d r>;  -- remove this

@{--
 - The identifier of a declaration or reference.
 - This uniquely identifies a reference or declaration from all others.
 -}
synthesized attribute str_id :: String
  occurs on Ref<d r>, Decl<d r>;  -- remove  this
flowtype str_id {} on Decl, Ref;  -- remove this

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
  s.name = scope_id (s.parent, s.scope_id);
}

aspect production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{
  ref.scope_id = s.scope_id;
  s.last_id = max (s.scope_id, ref.last_id);
  s.name = scope_id (s.parent, s.scope_id);
}


aspect production mk_decl
d::Decl<d r> ::= 
  objlang_inst::Decorated d with i
{
--  d.obj = objlang_inst;

  local parts::[String] = explode ("_", objlang_inst.str_id);
  d.name = head(parts);
  d.index = head (tail (parts));
  d.str_id = objlang_inst.str_id;
}


aspect production mk_decl_assoc
d::Decl<d r> ::= 
  objlang_inst::Decorated d with i
  module::Scope<d r> 
{
--  d.obj = objlang_inst;

  local parts::[String] = explode ("_", d.str_id);
  d.name = head(parts);
  d.index = head (tail (parts));
  module.scope_id = d.scope_id;
  d.str_id = objlang_inst.str_id;
}


aspect production mk_ref
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{
--  r.obj = objlang_inst;

  local parts::[String] = explode ("_", objlang_inst.str_id);
  r.name = head (parts);
  r.index = head (tail (parts));
  r.last_id = 0;
  r.str_id = objlang_inst.str_id;
}

aspect production mk_imp
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{
--  r.obj = objlang_inst;

  local parts::[String] = explode ("_", objlang_inst.str_id);
  r.name = head (parts);
  r.index = head (tail (parts));
  r.last_id = 0;
  r.str_id = objlang_inst.str_id;
}

aspect production mk_ref_qid
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
  qid_scope::Scope<d r> 
{
--  r.obj = objlang_inst;

  local parts::[String] = explode ("_", objlang_inst.str_id);
  r.name = head(parts);
  r.index = head (tail (parts));
  r.last_id = qid_scope.last_id;
  r.str_id = objlang_inst.str_id;
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
  ss.last_id = st.last_id + 1;
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
  name::Integer
{
  return
    case par of
      | nothing () -> toString (name)
      | just (p) -> p.name ++ "." ++ toString (name)
    end;
}
