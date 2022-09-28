grammar lmlang_basic;

inherited attribute env::[lm:IdDecl] occurs on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:Exp, 
  lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdDecl, lm:IdRef;

synthesized attribute pass_env::[lm:IdDecl] occurs on lm:Decl, lm:Exp, lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdDecl;

synthesized attribute myDecls::[lm:IdDecl] occurs on lm:IdRef;

synthesized attribute name::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute str::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute line::Integer occurs on lm:IdDecl, lm:IdRef;
synthesized attribute column::Integer occurs on lm:IdDecl, lm:IdRef;

monoid attribute bindings::[(lm:IdRef, lm:IdDecl)] occurs on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:Exp, 
  lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
  propagate bindings;

  list.env = [];
}

------------------------------------------------------------
---- Decl lists
------------------------------------------------------------

aspect production lm:decllist_list
top::lm:DeclList ::= decl::lm:Decl list::lm:DeclList
{
  propagate bindings;

  decl.env = top.env;
  list.env = decl.pass_env ++ top.env;
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
  propagate bindings;
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

{-
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
-}

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate bindings;

  decl.env = top.env;
  exp.env = decl.pass_env ++ top.env;

  top.pass_env = decl.pass_env;
}

aspect production lm:decl_exp
top::lm:Decl ::= exp::lm:Exp
{
  propagate bindings;

  exp.env = top.env;

  top.pass_env = [];
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{
  propagate bindings;

  list.env = top.env;
  exp.env = list.pass_env ++ top.env;

  top.pass_env = [];
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{
  propagate bindings;

  decl.env = top.env;
  exp.env = top.env;
  list.env = decl.pass_env ++ top.env;

  top.pass_env = list.pass_env ++ decl.pass_env;
}

aspect production lm:bindlist_nothing_seq
top::lm:BindListSeq ::=
{
  propagate bindings;

  top.pass_env = [];
}

------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

aspect production lm:exp_letrec
top::lm:Exp ::= list::lm:BindListRec exp::lm:Exp
{
  propagate bindings;

  list.env = top.env;
  exp.env = list.pass_env ++ top.env;

  top.pass_env = [];
}

aspect production lm:bindlist_list_rec
top::lm:BindListRec ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListRec
{
  propagate bindings;

  decl.env = exp.pass_env ++ list.pass_env ++ top.env;
  exp.env = decl.pass_env ++ list.pass_env ++ top.env;
  list.env = decl.pass_env ++ exp.pass_env ++ top.env;

  top.pass_env = decl.pass_env ++ exp.pass_env ++ list.pass_env;  
}

aspect production lm:bindlist_nothing_rec
top::lm:BindListRec ::=
{
  propagate bindings;

  top.pass_env = [];
}

------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

aspect production lm:exp_letpar
top::lm:Exp ::= list::lm:BindListPar exp::lm:Exp
{
  propagate bindings;

  list.env = top.env;
  exp.env = list.pass_env ++ top.env;

  top.pass_env = [];
}

aspect production lm:bindlist_list_par
top::lm:BindListPar ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListPar
{
  propagate bindings;

  decl.env = top.env;
  exp.env = top.env;
  list.env = top.env;

  top.pass_env = decl.pass_env ++ list.pass_env;
}

aspect production lm:bindlist_nothing_par
top::lm:BindListPar ::=
{
  propagate bindings;

  top.pass_env = [];
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

aspect production lm:exp_funfix
top::lm:Exp ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate bindings;

  decl.env = top.env;
  exp.env = decl.pass_env ++ top.env;
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate bindings;

  left.env = top.env;
  right.env = top.env;

  top.pass_env = [];
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate bindings;

  left.env = top.env;
  right.env = top.env;

  top.pass_env = [];
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
  propagate bindings;

  qid.env = top.env;

  top.pass_env = [];
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
  propagate bindings;

  top.pass_env = [];
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{
  propagate bindings;

  top.pass_env = [];
}

------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{
  propagate bindings;

  ref.env = top.env;
  qid.env = top.env;
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
  propagate bindings;

  ref.env = top.env;
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
  top.str = id.lexeme ++ "_" ++ toString(id.line) ++ "_" ++ toString(id.column);
  top.pass_env = [top];
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
  top.name = id.lexeme;
  top.line = id.line;
  top.column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(id.line) ++ "_" ++ toString(id.column);

  top.bindings := [head(
    filterMap(
      (\cur::lm:IdDecl -> 
        if cur.name == top.name then just((top, cur)) else nothing()),
      top.env
    )
  )];

}