grammar lmlang_basic;

synthesized attribute str::String occurs on lm:Program, lm:DeclList;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
}

------------------------------------------------------------
---- Declaration lists
------------------------------------------------------------

aspect production lm:decllist_list
top::lm:DeclList ::= decl::lm:Decl list::lm:DeclList
{
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

aspect production lm:decl_module
top::lm:Decl ::= decl::lm:IdDcl list::lm:DeclList
{
}

aspect production lm:decl_import
top::lm:Decl ::= qid::lm:Qid
{
}

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDcl exp::lm:Exp
{
}

aspect production lm:decl_exp
top::lm:Decl ::= exp::lm:Exp
{
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDcl exp::lm:Exp list::lm:BindListSeq
{
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
top::lm:BindListRec ::= id::lm:ID_t exp::lm:Exp list::lm:BindListRec
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
top::lm:BindListPar ::= id::lm:ID_t exp::lm:Exp list::lm:BindListPar
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
top::lm:Exp ::= decl::lm:IdDcl exp::lm:Exp
{
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
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
}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

aspect production lm:decl
top::lm:IdDcl ::= id::lm:ID_t
{
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
}