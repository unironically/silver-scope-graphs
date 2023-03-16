grammar scope_tree:ast;

import scope_tree:visser as res;

nonterminal Graph<d r>;

nonterminal Scope<d r>;
nonterminal Scopes<d r>;

nonterminal Decl<d r>;
nonterminal Decls<d r>;

nonterminal Ref<d r>;
nonterminal Refs<d r>;

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

synthesized attribute name :: String
  occurs on Ref<d r>, Decl<d r>;

synthesized attribute resolutions<d r> :: [Decorated Decl<d r>]
  occurs on Ref<d r>;

synthesized attribute dec_ref<d r> :: Decorated Ref<d r> occurs on Ref<d r>;

{-====================-}

abstract production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  root.parent = nothing ();
  root.qid_imp = nothing ();
}

{-====================-}

abstract production mk_scope
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
}

abstract production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{
  ref.scope = s;
  s.imps = case s.qid_imp of 
             nothing () -> [] 
           | just (r) -> [r] end;
  s.iqid_imps = ref.iqid_imps;
  s.decls = [];
}

abstract production mk_decl
  attribute name i occurs on d =>
d::Decl<d r> ::=
  objlang_inst::Decorated d with i
{
  d.name = objlang_inst.name;
  d.assoc_scope = nothing ();
}

abstract production mk_decl_assoc
  attribute name i occurs on d =>
d::Decl<d r> ::= 
  objlang_inst::Decorated d with i
  s::Scope<d r> 
{
  d.name = objlang_inst.name;
  s.parent = just (d.scope);
  s.qid_imp = nothing ();
  d.assoc_scope = just (s);
}

abstract production mk_ref
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{
  r.name = objlang_inst.name;
  r.iqid_imps = [];
  r.imps = [];
  r.resolutions = res:resolve_visser ([], r);

  {- Ugly solution -}
  local dec :: Ref<d r> = mk_ref (objlang_inst);
  dec.scope = r.scope;
  r.dec_ref = dec;
}

abstract production mk_imp
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{
  r.name = objlang_inst.name;
  r.iqid_imps = [r];
  r.imps = [];
  r.resolutions = res:resolve_visser ([], r);

  {- Ugly solution -}
  local dec :: Ref<d r> = mk_imp (objlang_inst);
  dec.scope = r.scope;
  r.dec_ref = dec;
}

abstract production mk_ref_qid
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
  s::Scope<d r> 
{
  r.name = objlang_inst.name;
  r.iqid_imps = s.iqid_imps;
  r.imps = [r];
  
  s.parent = nothing ();
  s.qid_imp = just (r);

  r.resolutions = res:resolve_visser ([], r);

  {- Ugly solution -}
  local dec :: Ref<d r> = mk_ref_qid (objlang_inst, s);
  dec.scope = r.scope;
  r.dec_ref = dec;  
}

{-====================-}

abstract production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{
  s.parent = ss.parent;
  s.qid_imp = nothing ();
  st.parent = ss.parent;
}

abstract production scope_nil
ss::Scopes<d r> ::=
{}

abstract production decl_cons
ds::Decls<d r> ::= 
  d::Decl<d r> 
  dt::Decls<d r>
{
  d.scope = ds.scope;
  dt.scope = ds.scope;
  ds.decls = d :: dt.decls;
}

abstract production decl_nil
ds::Decls<d r> ::= 
{
  ds.decls = [];
}

abstract production ref_cons
rs::Refs<d r> ::= 
  r::Ref<d r> 
  rt::Refs<d r>
{
  r.scope = rs.scope;
  rt.scope = rs.scope;

  rs.iqid_imps = r.iqid_imps ++ rt.iqid_imps;
  rs.imps = r.imps ++ rt.imps;
}

abstract production ref_nil
rs::Refs<d r> ::= 
{
  rs.iqid_imps = [];
  rs.imps = [];
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