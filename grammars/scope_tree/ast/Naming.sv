grammar scope_tree:ast;

{-====================-}

inherited attribute scope_id :: Integer 
  occurs on Scope<d r>, Scopes<d r>, Refs<d r>, Ref<d r>, Dcls<d r>, Dcl<d r>;

synthesized attribute last_id :: Integer 
  occurs on Ref<d r>, Scope<d r>, Scopes<d r>;

attribute name occurs on Scope<d r>;

 -- remove this - not sure we need this index.
synthesized attribute index :: String
  occurs on Ref<d r>, Dcl<d r>; 


flowtype str_id {} on Dcl, Ref; 
flowtype name {} on Dcl, Ref; 

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
  decls::Dcls<d r> 
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
dcl::Dcl<d r> ::= 
  objlang_inst::Decorated d with i
{
  -- d.obj_dcl = objlang_inst;

  -- local parts::[String] = explode ("_", objlang_inst.str_id);
  dcl.name = objlang_inst.name; -- head(parts);
  -- dcl.index = head (tail (parts));
  dcl.str_id = objlang_inst.str_id;
}


aspect production mk_decl_assoc
dcl::Dcl<d r> ::= 
  objlang_inst::Decorated d with i
  module::Scope<d r> 
{
--  d.obj = objlang_inst;

  --local parts::[String] = explode ("_", dcl.str_id);
  dcl.name = objlang_inst.name; --head(parts);
  --dcl.index = head (tail (parts));
  module.scope_id = dcl.scope_id;
  dcl.str_id = objlang_inst.str_id;
}


aspect production mk_ref
ref::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{
--  r.obj = objlang_inst;

  ref.name = objlang_inst.name;
  ref.str_id = objlang_inst.str_id;

  ref.last_id = 0;

  -- ref.index = head (tail (parts));
}

aspect production mk_imp
ref::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{
--  ref.obj = objlang_inst;

  --local parts::[String] = explode ("_", objlang_inst.str_id);
  ref.name = objlang_inst.name; -- head (parts);
  --ref.index = head (tail (parts));
  ref.last_id = 0;
  ref.str_id = objlang_inst.str_id;
}

aspect production mk_ref_qid
ref::Ref<d r> ::= 
  objlang_inst::Decorated r with i
  qid_scope::Scope<d r> 
{
--  ref.obj = objlang_inst;

  --local parts::[String] = explode ("_", objlang_inst.str_id);
  ref.name = objlang_inst.name; --head(parts);
  --ref.index = head (tail (parts));
  ref.last_id = qid_scope.last_id;
  ref.str_id = objlang_inst.str_id;
  qid_scope.scope_id = ref.scope_id;
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
ds::Dcls<d r> ::= 
  d::Dcl<d r> 
  dt::Dcls<d r>
{
  d.scope_id = ds.scope_id + 1;
  dt.scope_id = ds.scope_id + case d of mk_decl_assoc (_, _) -> 1 | _ -> 0 end;
}

aspect production decl_nil
ds::Dcls<d r> ::= 
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
