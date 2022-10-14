grammar lmlang_basic_scopetree;

inherited attribute scope::Scope occurs on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:Exp, 
  lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdDecl, lm:IdRef;

monoid attribute decls::[Decorated lm:IdDecl] occurs on lm:DeclList, lm:Decl, lm:IdDecl,
  lm:BindListRec, lm:BindListPar;
synthesized attribute ret_scope::Scope occurs on lm:BindListSeq;

synthesized attribute name::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute str::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute line::Integer occurs on lm:IdDecl, lm:IdRef;
synthesized attribute column::Integer occurs on lm:IdDecl, lm:IdRef;

monoid attribute bindings::[(lm:IdRef, Decorated lm:IdDecl)] occurs on lm:Program, lm:DeclList, lm:Decl, 
  lm:Qid, lm:Exp, lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdRef;
synthesized attribute my_decl::Decorated lm:IdDecl occurs on lm:IdRef;

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

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
  propagate bindings;

  local attribute global_scope :: Scope = cons_scope (
    list.decls,
    empty_scope()
  );

  list.scope = global_scope;
}

------------------------------------------------------------
---- Decl lists
------------------------------------------------------------

aspect production lm:decllist_list
top::lm:DeclList ::= decl::lm:Decl list::lm:DeclList
{
  propagate scope, decls, bindings;
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
  propagate decls, bindings;
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate scope, decls, bindings;
}

aspect production lm:decl_exp
top::lm:Decl ::= exp::lm:Exp
{
  propagate scope, decls, bindings;
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{
  propagate bindings;

  list.scope = top.scope;

  exp.scope = list.ret_scope;
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{
  propagate bindings;

  local attribute let_scope :: Scope = cons_scope (
    decl.decls,
    top.scope
  );

  top.ret_scope = list.ret_scope;

  exp.scope = top.scope;
  
  list.scope = let_scope;
}

aspect production lm:bindlist_nothing_seq
top::lm:BindListSeq ::=
{
  propagate bindings;

  top.ret_scope = top.scope;
}

------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

aspect production lm:exp_letrec
top::lm:Exp ::= list::lm:BindListRec exp::lm:Exp
{
  propagate bindings;

  local attribute let_scope :: Scope = cons_scope (
    list.decls,
    top.scope
  );

  list.scope = let_scope;

  exp.scope = let_scope;
}

aspect production lm:bindlist_list_rec
top::lm:BindListRec ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListRec
{
  propagate scope, bindings, decls;
}

aspect production lm:bindlist_nothing_rec
top::lm:BindListRec ::=
{
  propagate bindings, decls;
}

------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

aspect production lm:exp_letpar
top::lm:Exp ::= list::lm:BindListPar exp::lm:Exp
{
  propagate bindings;

  local attribute let_scope :: Scope = cons_scope (
    list.decls,
    top.scope
  );

  list.scope = top.scope;

  exp.scope = let_scope;
}

aspect production lm:bindlist_list_par
top::lm:BindListPar ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListPar
{
  propagate scope, bindings, decls;
}

aspect production lm:bindlist_nothing_par
top::lm:BindListPar ::=
{
  propagate bindings, decls;
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

aspect production lm:exp_funfix
top::lm:Exp ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate bindings;

  local attribute fun_scope :: Scope = cons_scope (
    decl.decls,
    top.scope
  );

  exp.scope = fun_scope;
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate scope, bindings;
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate scope, bindings;
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
  propagate scope, bindings;
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
  propagate bindings;
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{
  propagate bindings;
}

------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{
  propagate scope, bindings;
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
  propagate scope, bindings;
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

  top.decls := [top];
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
  top.name = id.lexeme;
  top.line = id.line;
  top.column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);

  local attribute resolutions :: [Decorated lm:IdDecl] = 
    (decorate top.scope with {look_for = top;}).resolutions;

  top.my_decl = head(resolutions);

  top.bindings := [(top, top.my_decl)];
}