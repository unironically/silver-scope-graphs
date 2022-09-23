grammar lmlang;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindListSeq;
nonterminal BindListRec;
nonterminal BindListPar;
nonterminal IdDecl;
nonterminal IdRef;

-- Attributes used in printing an AST
synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar, IdDecl, IdRef;

inherited attribute decl_type::Type occurs on IdDecl;
synthesized attribute type::Type occurs on Exp, Qid, IdRef;

monoid attribute errors::[String] occurs on Program, DeclList, Decl, Qid, Exp, 
  BindListSeq, BindListRec, BindListPar, IdDecl, IdRef;

------------------------------------------------------------
---- Program root
------------------------------------------------------------

abstract production prog 
top::Program ::= list::DeclList
{
  propagate errors;

  -- ast printing
  top.pp = "prog(" ++ list.pp ++ ")";
}

------------------------------------------------------------
---- sg:Decl lists
------------------------------------------------------------

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  propagate errors;

  -- ast printing
  top.pp = "decllist_list(" ++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decllist_nothing
top::DeclList ::=
{
  propagate errors;

  -- ast printing
  top.pp = "decllist_nothing()";
}

------------------------------------------------------------
---- sg:Decls
------------------------------------------------------------

abstract production decl_module
top::Decl ::= decl::IdDecl list::DeclList
{
  propagate errors;

  decl.decl_type = module_type();

  -- ast printing
  top.pp = "decl_module("++ decl.pp ++ "," ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  propagate errors;

  -- ast printing
  top.pp = "decl_import(" ++ qid.pp ++ ")";
}

abstract production decl_def
top::Decl ::= decl::IdDecl exp::Exp
{
  propagate errors;

  decl.decl_type = exp.type;

  -- ast printing
  top.pp = "decl_def(" ++ decl.pp ++ "," ++ exp.pp ++ ")";
}

abstract production decl_exp
top::Decl ::= exp::Exp
{
  propagate errors;

  -- ast printing
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
}

------------------------------------------------------------
---- Sequential let expressions
------------------------------------------------------------

abstract production exp_let
top::Exp ::= list::BindListSeq exp::Exp
{
  propagate errors;

  top.type = exp.type;

  -- ast printing
  top.pp = "exp_let(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_seq
top::BindListSeq ::= decl::IdDecl exp::Exp list::BindListSeq
{
  propagate errors;

  decl.decl_type = exp.type;

  -- ast printing
  top.pp = "bindlist_list_seq(" ++ decl.pp ++ "," ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_seq
top::BindListSeq ::=
{
  propagate errors;

  -- ast printing
  top.pp = "bindlist_nothing_seq()";
}

------------------------------------------------------------
---- Recursive let expressions
------------------------------------------------------------

abstract production exp_letrec
top::Exp ::= list::BindListRec exp::Exp
{
  propagate errors;

  top.type = exp.type;

  -- ast printing
  top.pp = "exp_letrec(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_rec
top::BindListRec ::= decl::IdDecl exp::Exp list::BindListRec
{
  propagate errors;

  decl.decl_type = exp.type;

  -- ast printing
  top.pp = "bindlist_list_rec(" ++ decl.pp ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_rec
top::BindListRec ::=
{
  propagate errors;

  -- ast printing
  top.pp = "bindlist_nothing_rec()";
}


------------------------------------------------------------
---- Parallel let expressions
------------------------------------------------------------

abstract production exp_letpar
top::Exp ::= list::BindListPar exp::Exp
{
  propagate errors;

  -- ast printing
  top.pp = "exp_letpar(" ++ list.pp ++ "," ++ exp.pp ++ ")";
}

abstract production bindlist_list_par
top::BindListPar ::= decl::IdDecl exp::Exp list::BindListPar
{
  propagate errors;

  decl.decl_type = exp.type;

  -- ast printing
  top.pp = "bindlist_list_par(" ++ decl.pp ++ " = " ++ exp.pp ++ "," ++ list.pp ++ ")";
}

abstract production bindlist_nothing_par
top::BindListPar ::=
{
  propagate errors;

  -- ast printing
  top.pp = "bindlist_nothing_par()";
}

------------------------------------------------------------
---- Other expressions
------------------------------------------------------------

abstract production exp_funfix
top::Exp ::= decl::IdDecl exp::Exp
{
  propagate errors;

  decl.decl_type = exp.type;

  -- ast printing
  top.pp = "exp_funfix(" ++ decl.pp ++ "," ++ exp.pp ++ ")";
}

abstract production exp_add
top::Exp ::= left::Exp right::Exp
{
  top.errors := case (left.type, right.type) of 
    | (int_type(), int_type()) -> []
    | (_, _) -> ["Mismatching types for expression " ++ top.pp ++ "\n"]
  end;

  top.type = int_type();

  -- ast printing
  top.pp = "exp_add(" ++ left.pp ++ "," ++ right.pp ++ ")";
}

abstract production exp_app
top::Exp ::= left::Exp right::Exp
{
  top.errors := case (left.type, right.type) of 
    | (fun_type(), t) -> []
    | (_, _) -> ["Mismatching types for expression " ++ top.pp ++ "\n"]
  end;

  top.type = right.type;

  -- ast printing
  top.pp = "exp_app(" ++ left.pp ++ "," ++ right.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{ 
  propagate errors;

  top.type = qid.type;

  -- ast printing
  top.pp ="exp_qid(" ++ qid.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{  
  propagate errors;

  top.type = int_type();

  -- ast printing
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}

abstract production exp_bool
top::Exp ::= val::Boolean
{
  propagate errors;

  top.type = bool_type();

  -- ast printing
  top.pp = "exp_bool(" ++ toString(val) ++ ")";
}


------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

abstract production qid_dot
top::Qid ::= ref::IdRef qid::Qid
{
  top.errors := case ref.type of 
    | module_type() -> []
    | _ -> ["Non-module type qid_dot at " ++ top.pp ++ "\n"]
  end;

  top.type = qid.type;

  -- ast printing
  top.pp = "qid_list(" ++ ref.pp ++ "," ++ qid.pp ++ ")";
}

abstract production qid_single
top::Qid ::= ref::IdRef
{
  propagate errors;

  top.type = ref.type;

  -- ast printing
  top.pp = "qid_single(" ++ ref.pp ++ ")";
}

------------------------------------------------------------
---- Decls / Refs
------------------------------------------------------------

abstract production decl
top::IdDecl ::= id::ID_t
{
  propagate errors;

  -- ast printing
  top.pp = "decl(" ++ id.lexeme ++ ")";
}

abstract production ref
top::IdRef ::= id::ID_t
{
  propagate errors;

  top.type = temp_type();

  -- ast printing
  top.pp = "ref(" ++ id.lexeme ++ ")";
}