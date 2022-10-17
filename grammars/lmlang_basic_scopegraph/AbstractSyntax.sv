grammar lmlang_basic_scopegraph;

-- Parent scope passed down the tree
inherited attribute scope::sg:Scope<lm:IdDecl lm:IdRef> occurs on lm:Program, lm:DeclList, lm:Decl,
  lm:Exp, lm:BindListSeq, lm:Qid, lm:IdDecl, lm:IdRef;

-- Decls/Refs/Imports passed up the tree to a scope node constructor
monoid attribute decls::[Decorated sg:Decl<lm:IdDecl lm:IdRef>] occurs on lm:DeclList, lm:Decl, 
  lm:IdDecl;
monoid attribute refs::[Decorated sg:Ref<lm:IdDecl lm:IdRef>] occurs on lm:DeclList, lm:Decl, 
  lm:Qid, lm:Exp, lm:IdRef, lm:BindListSeq;
monoid attribute imps::[Decorated sg:Ref<lm:IdDecl lm:IdRef>] occurs on lm:DeclList, lm:Decl, 
  lm:Qid, lm:Exp, lm:IdRef, lm:BindListSeq;

-- Passing the refs/imports from the RHS of a let expression to the scope(s) created on the left
inherited attribute letseq_refs::[Decorated sg:Ref<lm:IdDecl lm:IdRef>] occurs on lm:BindListSeq;
inherited attribute letseq_imps::[Decorated sg:Ref<lm:IdDecl lm:IdRef>] occurs on lm:BindListSeq;

-- Last scope constructed in a let binding expression, to be passed to exp of let
synthesized attribute ret_scope::sg:Scope<lm:IdDecl lm:IdRef> occurs on lm:BindListSeq;

-- Decl/Ref attributes derived from terminal
synthesized attribute str::String occurs on lm:IdDecl, lm:IdRef;
attribute sg:name, sg:line, sg:column occurs on lm:IdDecl, lm:IdRef;
flowtype sg:name {} on lm:IdDecl, lm:IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
  local attribute global_scope::sg:Scope<lm:IdDecl lm:IdRef> = sg:mk_scope_orphan (
    list.decls,
    list.refs,
    list.imps
  );

  list.scope = global_scope;
}

------------------------------------------------------------
---- Decl lists
------------------------------------------------------------

aspect production lm:decllist_list
top::lm:DeclList ::= decl::lm:Decl list::lm:DeclList
{
  propagate scope, decls, refs, imps;
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
  propagate decls, refs, imps;
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate scope, decls, refs, imps;
}

aspect production lm:decl_exp
top::lm:Decl ::= exp::lm:Exp
{
  propagate scope, decls, refs, imps;
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{
  list.scope = top.scope;
  list.letseq_refs = exp.refs;
  list.letseq_imps = exp.imps;

  exp.scope = list.ret_scope;
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{
  propagate letseq_refs, letseq_imps;

  local attribute let_scope::sg:Scope<lm:IdDecl lm:IdRef> = sg:mk_scope (
    just(top.scope),
    decl.decls,
    list.refs,
    list.imps
  );

  top.refs := exp.refs;
  top.imps := exp.imps;
  top.ret_scope = list.ret_scope;

  exp.scope = top.scope;
}

aspect production lm:bindlist_nothing_seq
top::lm:BindListSeq ::=
{
  top.refs := top.letseq_refs;
  top.imps := top.letseq_imps;
  top.ret_scope = top.scope;
}

------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

aspect production lm:exp_letrec
top::lm:Exp ::= list::lm:BindListRec exp::lm:Exp
{
}

aspect production lm:bindlist_list_rec
top::lm:BindListRec ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListRec
{
}

aspect production lm:bindlist_nothing_rec
top::lm:BindListRec ::=
{
}

------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

aspect production lm:exp_letpar
top::lm:Exp ::= list::lm:BindListPar exp::lm:Exp
{
}

aspect production lm:bindlist_list_par
top::lm:BindListPar ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListPar
{
}

aspect production lm:bindlist_nothing_par
top::lm:BindListPar ::=
{
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

aspect production lm:exp_funfix
top::lm:Exp ::= decl::lm:IdDecl exp::lm:Exp
{
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate scope, refs, imps;
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate scope, refs, imps;
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
  propagate scope, refs, imps;
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
  propagate scope, refs, imps;
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{
  propagate scope, refs, imps;
}

------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
  propagate scope, refs, imps;
}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

aspect production lm:decl
top::lm:IdDecl ::= id::lm:ID_t
{
  top.sg:name = id.lexeme;
  top.sg:line = id.line;
  top.sg:column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(top.sg:line) ++ "_" ++ toString(top.sg:column);

  local attribute graph_decl::sg:Decl<lm:IdDecl lm:IdRef> = sg:mk_decl (
    top.scope,
    top
  );

  top.decls := [graph_decl];
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
  top.sg:name = id.lexeme;
  top.sg:line = id.line;
  top.sg:column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(top.sg:line) ++ "_" ++ toString(top.sg:column);

  local attribute graph_ref::sg:Ref<lm:IdDecl lm:IdRef> = sg:mk_ref (
    top.scope,
    top
  );

  top.refs := [graph_ref];
}

{-
def a = 0 def b = 1 def c = 2 letseq a = c  b = a  c = b in a + b + c
    4         14        24           37  41 43  47 49  53   58  62  66  
  Should get:
  - c_1_41 -> c_1_24
  - a_1_47 -> a_1_37
  - b_1_53 -> b_1_43
  - a_1_58 -> a_1_37
  - b_1_62 -> b_1_43
  - c_1_66 -> c_1_49

def a = 0 def b = 1 def c = 2 letpar a = c  b = a  c = b in a + b + c
    4         14        24           37  41 43  47 49  53   58  62  66  
  Should get:
  - c_1_41 -> c_1_49
  - a_1_47 -> a_1_37
  - b_1_53 -> b_1_43
  - a_1_58 -> a_1_37
  - b_1_62 -> b_1_53
  - c_1_66 -> c_1_49  

def a = 0 def b = 1 def c = 2 letrec a = c  b = a  c = b in a + b + c
    4         14        24           37  41 43  47 49  53   58  62  66      
  Should get:
  - c_1_41 -> c_1_24
  - a_1_47 -> a_1_4
  - b_1_53 -> b_1_14
  - a_1_58 -> a_1_37
  - b_1_62 -> b_1_43
  - c_1_66 -> c_1_49      
-}