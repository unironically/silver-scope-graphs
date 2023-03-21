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

synthesized attribute name :: String
  occurs on Ref<d r>, Decl<d r>;
synthesized attribute resolutions<d r> :: [Decorated Decl<d r>]
  occurs on Ref<d r>;
synthesized attribute dec_ref<d r> :: (Decorated Ref<d r> ::= Ref<d r>)
  occurs on Graph<d r>;

{-====================-}

abstract production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  g.dec_ref = (\r::Ref<d r> -> 
    head (filter ((\dr::Decorated Ref<d r> -> dr.str == r.str), root.refs)));
}

{-====================-}

abstract production mk_scope
s::Scope<d r> ::= 
  decls::Decls<d r> 
  refs::Refs<d r> 
  children::Scopes<d r>
{}

abstract production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{}

abstract production mk_decl
  attribute name i occurs on d =>
d::Decl<d r> ::=
  objlang_inst::Decorated d with i
{ d.name = objlang_inst.name; }

abstract production mk_decl_assoc
  attribute name i occurs on d =>
d::Decl<d r> ::= 
  objlang_inst::Decorated d with i
  s::Scope<d r> 
{ d.name = objlang_inst.name; }

abstract production mk_ref
  attribute name i occurs on objr =>
r::Ref<d r> ::= 
  objlang_inst::Decorated objr with i
{ r.name = objlang_inst.name; }

abstract production mk_imp
  attribute name i occurs on objr =>
r::Ref<d r> ::= 
  objlang_inst::Decorated objr with i
{ r.name = objlang_inst.name; }

abstract production mk_ref_qid
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
  s::Scope<d r> 
{ r.name = objlang_inst.name; }

{-====================-}

abstract production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{}

abstract production scope_nil
ss::Scopes<d r> ::=
{}

abstract production decl_cons
ds::Decls<d r> ::= 
  d::Decl<d r> 
  dt::Decls<d r>
{}

abstract production decl_nil
ds::Decls<d r> ::= 
{}

abstract production ref_cons
rs::Refs<d r> ::= 
  r::Ref<d r> 
  rt::Refs<d r>
{}

abstract production ref_nil
rs::Refs<d r> ::= 
{}