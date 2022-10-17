grammar lmlang_basic_scopegraph;

------------------------------------------------------------
---- Typing nonterminal
------------------------------------------------------------

nonterminal Type;

abstract production int_type
top::Type ::=
{}

abstract production bool_type
top::Type ::=
{}

------------------------------------------------------------
---- Aspects
------------------------------------------------------------

-- Attributes
synthesized attribute type::Type occurs on lm:IdRef, lm:Qid, lm:Exp;
inherited attribute decl_type::Type occurs on lm:IdDecl;

monoid attribute type_errors::[String] occurs on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:Exp, 
  lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdRef;

propagate type_errors on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:IdRef;

-- Name declaration
aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{ 
  decl.decl_type = exp.type; 
}

-- Binding lists
aspect production lm:exp_let
top::lm:Exp ::= list::lm:BindListSeq exp::lm:Exp
{ propagate type_errors; }

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{ 
  propagate type_errors;
  decl.decl_type = exp.type; 
}

aspect production lm:bindlist_nothing_seq
top::lm:BindListSeq ::=
{ propagate type_errors; }

aspect production lm:exp_letrec
top::lm:Exp ::= list::lm:BindListRec exp::lm:Exp
{ propagate type_errors; }

aspect production lm:bindlist_nothing_rec
top::lm:BindListRec ::=
{ propagate type_errors; }

aspect production lm:exp_letpar
top::lm:Exp ::= list::lm:BindListPar exp::lm:Exp
{ propagate type_errors; }

aspect production lm:bindlist_list_par
top::lm:BindListPar ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListPar
{
  propagate type_errors;
  decl.decl_type = exp.type; 
}

aspect production lm:bindlist_nothing_par
top::lm:BindListPar ::=
{ propagate type_errors; }

-- Exprs
aspect production lm:exp_funfix
top::lm:Exp ::= decl::lm:IdDecl exp::lm:Exp
{ 
  propagate type_errors; 
  decl.decl_type = exp.type; 
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{ 
  propagate type_errors;
  
  top.type = int_type(); 

  top.type_errors <-
    case (left.type, right.type) of
      | (int_type(), int_type()) -> []
      | _ -> ["Tried to use add using non-integer expression(s)!"]
    end;
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate type_errors; 
  top.type = left.type; 
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{ 
  propagate type_errors;
  top.type = qid.type; 
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{ 
  propagate type_errors;
  top.type = int_type(); 
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{ 
  propagate type_errors;
  top.type = bool_type(); 
}

-- Qualified identifiers
aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{ 
  top.type = qid.type; 
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{ 
  top.type = ref.type; 
}

-- Ref
aspect production lm:ref
top::lm:IdRef ::= id::lm:ID_t
{ 
  --top.type = top.my_decl.decl_type; 
}