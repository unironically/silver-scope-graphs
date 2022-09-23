grammar lmlang;

synthesized attribute ast<a>::a;

nonterminal Program_c with ast<Program>;
nonterminal DeclList_c with ast<DeclList>;
nonterminal Decl_c with ast<Decl>;
nonterminal Qid_c with ast<Qid>;
nonterminal Exp_c with ast<Exp>;
nonterminal BindList_c_seq with ast<BindListSeq>;
nonterminal BindList_c_rec with ast<BindListRec>;
nonterminal BindList_c_par with ast<BindListPar>;
nonterminal IdDecl_c with ast<IdDecl>;
nonterminal IdRef_c with ast<IdRef>;

concrete production program_c
top::Program_c ::= list::DeclList_c
{
  top.ast = prog(list.ast);
}

concrete production decllist_c_list
top::DeclList_c ::= decl::Decl_c list::DeclList_c
{
  top.ast = decllist_list(decl.ast, list.ast);
}

concrete production decllist_c_nothing
top::DeclList_c ::=
{
  top.ast = decllist_nothing();
}

--------------------------------------------------------------------
-- Not included in the grammar given in the publication - but seems necessary for the examples given.
-- Removing for now to comply with grammar in theory of name resolution
--------------------------------------------------------------------
concrete production decl_c_exp
top::Decl_c ::= exp::Exp_c
{
  top.ast = decl_exp(exp.ast);
}

concrete production decl_c_import
top::Decl_c ::= Import_t qid::Qid_c
{
  top.ast = decl_import(qid.ast);
}

concrete production decl_c_module
top::Decl_c ::= Module_t id::IdDecl_c LCurly_t list::DeclList_c RCurly_t
{
  top.ast = decl_module(id.ast, list.ast);
} 

concrete production decl_c_def
top::Decl_c ::= Def_t id::IdDecl_c Eq_t exp::Exp_c
{
  top.ast = decl_def(id.ast, exp.ast);
}

concrete production exp_c_let
top::Exp_c ::= Let_t list::BindList_c_seq In_t exp::Exp_c
{
  top.ast = exp_let(list.ast, exp.ast);
}

concrete production bindlist_c_seq_nothing
top::BindList_c_seq ::=
{
  top.ast = bindlist_nothing_seq();
}

concrete production bindlist_c_seq_list
top::BindList_c_seq ::= id::IdDecl_c Eq_t exp::Exp_c list::BindList_c_seq
{
  top.ast = bindlist_list_seq(id.ast, exp.ast, list.ast);
}

concrete production exp_c_letrec
top::Exp_c ::= LetRec_t list::BindList_c_rec In_t exp::Exp_c
{
  top.ast = exp_letrec(list.ast, exp.ast);
}

concrete production bindlist_c_rec_nothing
top::BindList_c_rec ::=
{
  top.ast = bindlist_nothing_rec();
}

concrete production bindlist_c_rec_list
top::BindList_c_rec ::= id::IdDecl_c Eq_t exp::Exp_c list::BindList_c_rec
{
  top.ast = bindlist_list_rec(id.ast, exp.ast, list.ast);
}

concrete production exp_c_letpar
top::Exp_c ::= LetPar_t list::BindList_c_par In_t exp::Exp_c
{
  top.ast = exp_letpar(list.ast, exp.ast);
}

concrete production bindlist_c_par_nothing
top::BindList_c_par ::=
{
  top.ast = bindlist_nothing_par();
}

concrete production bindlist_c_par_list
top::BindList_c_par ::= id::IdDecl_c Eq_t exp::Exp_c list::BindList_c_par
{
  top.ast = bindlist_list_par(id.ast, exp.ast, list.ast);
}

concrete production exp_c_fun
top::Exp_c ::= Fun_t id::IdDecl_c LCurly_t exp::Exp_c RCurly_t
{
  top.ast = exp_funfix(id.ast, exp.ast);
}

concrete production exp_c_add
top::Exp_c ::= left::Exp_c Plus_t right::Exp_c
{
  top.ast = exp_add(left.ast, right.ast);
}

concrete production exp_c_app
top::Exp_c ::= left::Exp_c App_t right::Exp_c
{
  top.ast = exp_app(left.ast, right.ast);
}

concrete production exp_c_qid
top::Exp_c ::= qid::Qid_c 
{
  top.ast = exp_qid(qid.ast);
}

concrete production qid_c_dot
top::Qid_c ::= id::IdRef_c Dot_t qid::Qid_c
{
  top.ast = qid_dot(id.ast, qid.ast);
}

concrete production qid_c_single
top::Qid_c ::= id::IdRef_c
{
  top.ast = qid_single(id.ast);
}

concrete production exp_c_int
top::Exp_c ::= val::Int_t
{
  top.ast = exp_int(val);
}

concrete production exp_c_bool_true
top::Exp_c ::= val::True_t
{
  top.ast = exp_bool(true);
}

concrete production exp_c_bool_false
top::Exp_c ::= val::False_t
{
  top.ast = exp_bool(false);
}

concrete production decl_c
top::IdDecl_c ::= id::ID_t
{
  top.ast = decl(id);
}

concrete production ref_c
top::IdRef_c ::= id::ID_t
{
  top.ast = ref(id);
}