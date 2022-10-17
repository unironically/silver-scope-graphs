grammar lmlang_basic_scopegraph;

synthesized attribute name::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute str::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute line::Integer occurs on lm:IdDecl, lm:IdRef;
synthesized attribute column::Integer occurs on lm:IdDecl, lm:IdRef;
--synthesized attribute my_decl::lm:IdDecl occurs on lm:IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

aspect production lm:prog
top::lm:Program ::= list::lm:DeclList
{
}

------------------------------------------------------------
---- Decl lists
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

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
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
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
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
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
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
}

aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{
  top.name = id.lexeme;
  top.line = id.line;
  top.column = id.column;
  top.str = id.lexeme ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
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