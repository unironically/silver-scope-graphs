grammar lmlang_basic_scopegraph;

-- Parent scope passed down the tree
inherited attribute scope::Scope occurs on lm:Program, lm:DeclList, lm:Decl,
  lm:Exp, lm:BindListSeq, lm:Qid, lm:IdDecl, lm:IdRef, lm:BindListRec, lm:BindListPar;

-- Decls/Refs/Imports passed up the tree to a scope node constructor
monoid attribute decls::[Decorated Decl] occurs on lm:DeclList, lm:Decl, 
  lm:IdDecl, lm:BindListRec, lm:BindListPar;
monoid attribute refs::[Ref] occurs on lm:DeclList, lm:Decl, 
  lm:Qid, lm:Exp, lm:IdRef, lm:BindListSeq, lm:BindListRec, lm:BindListPar;
monoid attribute imps::[Ref] occurs on lm:DeclList, lm:Decl, 
  lm:Qid, lm:Exp, lm:BindListSeq, lm:BindListRec, lm:BindListPar;

-- Associated scope of a module declaration
inherited attribute assoc_scope::Maybe<Scope> occurs on lm:IdDecl;

synthesized attribute sg_ref::Ref occurs on lm:IdRef;

-- Passing the refs/imports from the RHS of a let expression to the scope(s) created on the left
inherited attribute letseq_refs::[Ref] occurs on lm:BindListSeq;
inherited attribute letseq_imps::[Ref] occurs on lm:BindListSeq;

monoid attribute bindings::[(lm:IdRef, Decorated lm:IdDecl)] occurs on lm:IdRef, lm:Qid,
  lm:Exp, lm:Decl, lm:DeclList, lm:Program, lm:BindListSeq, lm:BindListRec, lm:BindListPar;

-- Last scope constructed in a let binding expression, to be passed to exp of let
synthesized attribute ret_scope::Scope occurs on lm:BindListSeq;

-- Decl/Ref attributes derived from terminal
attribute str, name, line, column occurs on lm:IdDecl, lm:IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
  propagate bindings;

  local attribute global_scope::Scope = mk_scope_orphan (
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
  propagate scope, decls, refs, imps, bindings;
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
  propagate scope, decls, refs, imps, bindings;
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

aspect production lm:decl_module
top::lm:Decl ::= decl::lm:IdDecl list::lm:DeclList
{
  propagate bindings;

  local attribute module_scope::Scope = mk_scope (
    just(top.scope),
    list.decls,
    list.refs,
    list.imps
  );

  top.decls := decl.decls;
  top.refs := [];
  top.imps := [];

  decl.scope = top.scope;
  decl.assoc_scope = just(module_scope);

  list.scope = module_scope;
}

aspect production lm:decl_import
top::lm:Decl ::= qid::lm:Qid
{
  propagate scope, decls, refs, imps, bindings;
}

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate scope, decls, refs, imps, bindings;

  decl.assoc_scope = nothing();
}

aspect production lm:decl_exp
top::lm:Decl ::= exp::lm:Exp
{
  propagate scope, refs, decls, imps, bindings;
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{
  propagate bindings;

  top.refs := [];
  top.imps := [];

  list.scope = top.scope;
  list.letseq_refs = exp.refs;
  list.letseq_imps = exp.imps;

  exp.scope = list.ret_scope;
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{
  propagate letseq_refs, letseq_imps, bindings;

  local attribute let_scope::Scope = mk_scope (
    just(top.scope),
    decl.decls,
    list.refs,
    list.imps
  );

  top.refs := exp.refs;
  top.imps := exp.imps;
  top.ret_scope = list.ret_scope;

  decl.scope = let_scope;
  decl.assoc_scope = nothing(); -- would be just(module_decl)

  exp.scope = top.scope;

  list.scope = let_scope;
}

aspect production lm:bindlist_nothing_seq
top::lm:BindListSeq ::=
{
  propagate bindings;

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
  propagate bindings;

  local attribute let_scope::Scope = mk_scope (
    just(top.scope),
    list.decls,
    list.refs ++ exp.refs,
    list.imps ++ exp.imps
  );

  top.refs := [];
  top.imps := [];

  list.scope = let_scope;

  exp.scope = let_scope;
}

aspect production lm:bindlist_list_rec
top::lm:BindListRec ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListRec
{
  propagate scope, decls, refs, imps, bindings;
  decl.assoc_scope = nothing();
}

aspect production lm:bindlist_nothing_rec
top::lm:BindListRec ::=
{
  propagate scope, decls, refs, imps, bindings;
}

------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

aspect production lm:exp_letpar
top::lm:Exp ::= list::lm:BindListPar exp::lm:Exp
{
  propagate refs, imps, bindings;

  local attribute let_scope::Scope = mk_scope (
    just(top.scope),
    list.decls,
    exp.refs,
    exp.imps
  );

  list.scope = top.scope;

  exp.scope = let_scope;
}

aspect production lm:bindlist_list_par
top::lm:BindListPar ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListPar
{
  propagate scope, decls, refs, imps, bindings;
  decl.assoc_scope = nothing();
}

aspect production lm:bindlist_nothing_par
top::lm:BindListPar ::=
{
  propagate scope, decls, refs, imps, bindings;
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

aspect production lm:exp_funfix
top::lm:Exp ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate scope, refs, imps, bindings;
  decl.assoc_scope = nothing();
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate scope, refs, imps, bindings;
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate scope, refs, imps, bindings;
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
  propagate scope, refs, imps, bindings;
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
  propagate scope, refs, imps, bindings;
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{
  propagate scope, refs, imps, bindings;
}

------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{
  propagate imps, bindings;

  local attribute qid_scope::Scope = mk_scope_orphan (
    [],
    qid.refs,
    [ref.sg_ref]
  );

  top.refs := [ref.sg_ref];

  ref.scope = top.scope;

  qid.scope = qid_scope;

}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
  propagate scope, bindings;

  top.refs := [ref.sg_ref];
  top.imps := [ref.sg_ref]; -- for iqid import
}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

aspect production lm:decl
top::lm:IdDecl ::= id::lm:ID_t
{
  top.name = id.lexeme;
  top.line = id.line;
  top.column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);

  local attribute graph_decl::Decl = mk_decl (
    top.scope,
    top.assoc_scope,
    top
  );

  top.decls := [graph_decl];
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
  top.name = id.lexeme;
  top.line = id.line;
  top.column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);

  local attribute graph_ref::Ref = mk_ref (
    top.scope,
    top
  );

  top.sg_ref = graph_ref;
  top.refs := [graph_ref];

  top.bindings := 
    let res::[Decorated Decl] = 
      (decorate top.scope with 
        { sg_look_for = graph_ref; 
          sg_seen_scopes = [];
          sg_seen_imports = []; }
      ).sg_resolutions
    in 
      let res2::[(lm:IdRef, Decorated lm:IdDecl)] = 
        [(top, head(res).sg_ast_decl)]
      in unsafeTrace(res2, printT("[#] Trying to resolve ref: " ++ top.str 
        ++ " size: " ++ toString(length(res)) ++ " - " ++ (if length(res) > 0 then head(res).str else "") ++ "\n", unsafeIO()))
    end end;

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