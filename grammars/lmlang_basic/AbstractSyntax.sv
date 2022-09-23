grammar lmlang_basic;

inherited attribute env::[()] occurs on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:Exp, 
  lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdDecl, lm:IdRef;

synthesized attribute pass_env::[()] occurs on lm:Decl, lm:Exp, lm:BindListSeq, lm:IdDecl;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
  list.env = [];
}

------------------------------------------------------------
---- Decl lists
------------------------------------------------------------

aspect production lm:decllist_list
top::lm:DeclList ::= decl::lm:Decl list::lm:DeclList
{
  decl.env = top.env;
  list.env = decl.pass_env;
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

aspect production lm:decl_module
top::lm:Decl ::= decl::lm:IdDecl list::lm:DeclList
{
  decl.env = top.env;
  list.env = decl.pass_env;
}

aspect production lm:decl_import
top::lm:Decl ::= qid::lm:Qid
{
  qid.env = top.env;
}

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{
  decl.env = top.env;
  exp.env = decl.pass_env;
}

aspect production lm:decl_exp
top::lm:Decl ::= exp::lm:Exp
{
  exp.env = top.env;
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{
  list.env = top.env;
  exp.env = list.pass_env;
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{
  decl.env = top.env;
  exp.env = decl.pass_env;
  top.pass_env = list.pass_env;
}

aspect production lm:bindlist_nothing_seq
top::lm:BindListSeq ::=
{
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
  decl.env = top.env;
  exp.env = decl.pass_env;
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  left.env = top.env ++ right.pass_env;
  right.env = top.env ++ left.pass_env;
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  left.env = top.env ++ right.pass_env;
  right.env = top.env ++ left.pass_env;
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
  qid.env = top.env;
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{
}

------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{
  ref.env = top.env;
  qid.env = top.env;
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
  ref.env = top.env;
}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

aspect production lm:decl
top::lm:IdDecl ::= id::lm:ID_t
{
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
}