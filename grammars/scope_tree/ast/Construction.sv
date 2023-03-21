grammar scope_tree:ast;

{-====================-}

inherited attribute parent<d r> :: Maybe<Decorated Scope<d r>> 
  occurs on Scope<d r>, Scopes<d r>;
inherited attribute scope<d r> :: Decorated Scope<d r> 
  occurs on Decl<d r>, Decls<d r>, Ref<d r>, Refs<d r>;
synthesized attribute assoc_scope<d r> :: Maybe<Decorated Scope<d r>> 
  occurs on Decl<d r>;

synthesized attribute imps<d r> :: [Decorated Ref<d r>] 
  occurs on Ref<d r>, Refs<d r>, Scope<d r>;
synthesized attribute iqid_imps<d r> :: [Decorated Ref<d r>] 
  occurs on Ref<d r>, Refs<d r>, Scope<d r>;
inherited attribute qid_imp<d r> :: Maybe<Decorated Ref<d r>> 
  occurs on Scope<d r>;

synthesized attribute decls<d r> :: [Decorated Decl<d r>]
  occurs on Scope<d r>, Decls<d r>;
synthesized attribute refs<d r> :: [Decorated Ref<d r>]
  occurs on Scope<d r>, Refs<d r>, Ref<d r>, Decls<d r>, Decl<d r>, Scopes<d r>;

{-====================-}

aspect production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  root.parent = nothing ();
  root.qid_imp = nothing ();
}

{-====================-}

aspect production mk_scope
s::Scope<d r> ::= 
  decls::Decls<d r> 
  refs::Refs<d r> 
  children::Scopes<d r>
{
  decls.scope = s;
  refs.scope = s;
  children.parent = just (s);

  s.imps = case s.qid_imp of 
             nothing () -> refs.iqid_imps 
           | just (r) -> r::refs.iqid_imps end;
  s.iqid_imps = [];
  s.decls = decls.decls;
  s.refs = refs.refs ++ decls.refs ++ children.refs;
}

aspect production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{
  ref.scope = s;
  s.imps = case s.qid_imp of 
             nothing () -> [] 
           | just (r) -> [r] end;
  s.iqid_imps = ref.iqid_imps;
  s.decls = [];
  s.refs = ref.refs;
}


aspect production mk_decl
d::Decl<d r> ::= 
  _
{
  d.assoc_scope = nothing ();
  d.refs = [];
}


aspect production mk_decl_assoc
d::Decl<d r> ::= 
  _
  module::Scope<d r> 
{
  module.parent = just (d.scope);
  module.qid_imp = nothing ();
  d.assoc_scope = just (module);
  d.refs = module.refs;
}


aspect production mk_ref
r::Ref<d r> ::= 
  _
{
  r.iqid_imps = [];
  r.imps = [];
  r.refs = [r];
}

aspect production mk_imp
r::Ref<d r> ::= 
  _
{
  r.iqid_imps = [r];
  r.imps = [];
  r.refs = [r];
}

aspect production mk_ref_qid
r::Ref<d r> ::= 
  _
  qid_scope::Scope<d r> 
{
  r.iqid_imps = qid_scope.iqid_imps;
  r.imps = [r];
  r.refs = r :: qid_scope.refs;
  
  qid_scope.parent = nothing ();
  qid_scope.qid_imp = just (r);
}

{-====================-}

aspect production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{
  s.parent = ss.parent;
  s.qid_imp = nothing ();
  st.parent = ss.parent;
  ss.refs = s.refs ++ st.refs;
}

aspect production scope_nil
ss::Scopes<d r> ::=
{
  ss.refs = [];
}

aspect production decl_cons
ds::Decls<d r> ::= 
  d::Decl<d r> 
  dt::Decls<d r>
{
  d.scope = ds.scope;
  dt.scope = ds.scope;
  ds.decls = d :: dt.decls;
  ds.refs = d.refs ++ dt.refs;
}

aspect production decl_nil
ds::Decls<d r> ::= 
{
  ds.decls = [];
  ds.refs = [];
}

aspect production ref_cons
rs::Refs<d r> ::= 
  r::Ref<d r> 
  rt::Refs<d r>
{
  r.scope = rs.scope;
  rt.scope = rs.scope;

  rs.iqid_imps = r.iqid_imps ++ rt.iqid_imps;
  rs.imps = r.imps ++ rt.imps;
  rs.refs = r.refs ++ rt.refs;
}

aspect production ref_nil
rs::Refs<d r> ::= 
{
  rs.iqid_imps = [];
  rs.imps = [];
  rs.refs = [];
}

{-====================-}

function combine_decls
Decls<d r> ::= 
  ds1::Decls<d r> 
  ds2::Decls<d r>
{
  return
    case ds1 of
    | decl_nil () -> ds2
    | decl_cons (d, dt) -> decl_cons (d, combine_decls (dt, ds2))
    end;
}

function combine_refs
Refs<d r> ::= 
  rs1::Refs<d r> 
  rs2::Refs<d r>
{
  return
    case rs1 of
    | ref_nil () -> rs2
    | ref_cons (r, rt) -> ref_cons (r, combine_refs (rt, rs2))
    end;
}