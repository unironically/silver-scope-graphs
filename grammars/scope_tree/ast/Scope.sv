grammar scope_tree:ast;

nonterminal Graph<a>;

nonterminal Scope<a>;
nonterminal Scopes<a>;

nonterminal Decl<a>;
nonterminal Decls<a>;

nonterminal Ref<a>;
nonterminal Refs<a>;

{-====================-}

inherited attribute parent<a> :: Maybe<Decorated Scope<a>> 
  occurs on Scope<a>, Scopes<a>;
inherited attribute scope<a> :: Decorated Scope<a> 
  occurs on Decl<a>, Decls<a>, Ref<a>, Refs<a>;
synthesized attribute assoc_scope<a> :: Maybe<Scope<a>> 
  occurs on Decl<a>;

inherited attribute qid_imp<a> :: Maybe<Decorated Ref<a>> 
  occurs on Scope<a>;
synthesized attribute imps<a> :: [Decorated Ref<a>] 
  occurs on Ref<a>, Refs<a>, Scope<a>;
synthesized attribute iqid_imps<a> :: [Decorated Ref<a>] 
  occurs on Ref<a>, Refs<a>, Scope<a>;

synthesized attribute name :: String;

{-====================-}

abstract production mk_graph
g::Graph<a> ::= 
  root::Scope<a>
{
  root.parent = nothing ();
  root.qid_imp = nothing ();
}

{-====================-}

abstract production mk_scope
s::Scope<a> ::= 
  decls::Decls<a> 
  refs::Refs<a> 
  children::Scopes<a>
{
  decls.scope = s;
  refs.scope = s;
  children.parent = just (s);

  s.imps = case s.qid_imp of 
             nothing () -> refs.iqid_imps 
           | just (r) -> r::refs.iqid_imps end;
  s.iqid_imps = [];
}

abstract production mk_scope_qid
s::Scope<a> ::= 
  ref::Ref<a>
{
  ref.scope = s;
  s.imps = case s.qid_imp of 
             nothing () -> [] 
           | just (r) -> [r] end;
  s.iqid_imps = ref.iqid_imps;
}

abstract production mk_decl
  attribute name i occurs on a =>
d::Decl<a> ::= 
  id::String 
  objlang_inst::Decorated a with i
{
  d.assoc_scope = nothing ();
}

abstract production mk_decl_assoc
  attribute name i occurs on a =>
d::Decl<a> ::= 
  id::String 
  s::Scope<a> 
  objlang_inst::Decorated a with i
{
  s.parent = just (d.scope);
  s.qid_imp = nothing ();
  d.assoc_scope = just (s);
}

abstract production mk_ref
  attribute name i occurs on a =>
r::Ref<a> ::= 
  id::String 
  objlang_inst::Decorated a with i
{
  r.iqid_imps = [];
  r.imps = [];
}

abstract production mk_imp
  attribute name i occurs on a =>
r::Ref<a> ::= 
  id::String 
  objlang_inst::Decorated a with i
{
  r.iqid_imps = [r];
  r.imps = [];
}

abstract production mk_ref_qid
  attribute name i occurs on a =>
r::Ref<a> ::= 
  id::String 
  s::Scope<a> 
  objlang_inst::Decorated a with i
{
  r.iqid_imps = s.iqid_imps;
  r.imps = [r];
  
  s.parent = nothing ();
  s.qid_imp = just (r);
}

{-====================-}

abstract production scope_cons
ss::Scopes<a> ::= 
  s::Scope<a> 
  st::Scopes<a>
{
  s.parent = ss.parent;
  s.qid_imp = nothing ();
  st.parent = ss.parent;
}

abstract production scope_nil
ss::Scopes<a> ::=
{}

abstract production decl_cons
ds::Decls<a> ::= 
  d::Decl<a> 
  dt::Decls<a>
{
  d.scope = ds.scope;
  dt.scope = ds.scope;
}

abstract production decl_nil
ds::Decls<a> ::= 
{}

abstract production ref_cons
rs::Refs<a> ::= 
  r::Ref<a> 
  rt::Refs<a>
{
  r.scope = rs.scope;
  rt.scope = rs.scope;

  rs.iqid_imps = r.iqid_imps ++ rt.iqid_imps;
  rs.imps = r.imps ++ rt.imps;
}

abstract production ref_nil
rs::Refs<a> ::= 
{
  rs.iqid_imps = [];
  rs.imps = [];
}

{-====================-}

function combine_decls
Decls<a> ::= 
  ds1::Decls<a> 
  ds2::Decls<a>
{
  return
    case ds1 of
    | decl_nil () -> ds2
    | decl_cons (d, dt) -> decl_cons (d, combine_decls (dt, ds2))
    end;
}

function combine_refs
Refs<a> ::= 
  rs1::Refs<a> 
  rs2::Refs<a>
{
  return
    case rs1 of
    | ref_nil () -> rs2
    | ref_cons (r, rt) -> ref_cons (r, combine_refs (rt, rs2))
    end;
}