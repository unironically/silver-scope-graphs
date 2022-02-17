grammar lmlang;

synthesized attribute ast<a>::a;

nonterminal Program_c with ast<Program>;
nonterminal DeclList_c with ast<DeclList>;
nonterminal Decl_c with ast<Decl>;
nonterminal Qid_c with ast<Qid>;
nonterminal Exp_c with ast<Exp>;
nonterminal BindList_c with ast<BindList>;
nonterminal Bind_c with ast<Bind>;

concrete production program_c
top::Program_c ::= list::DeclList_c
{
  top.ast = prog(list.ast);
}

concrete production decllist_c_single
top::DeclList_c ::= decl::Decl_c
{
  top.ast = decllist_single(decl.ast);
}

concrete production decllist_c_list
top::DeclList_c ::= decl::Decl_c list::DeclList_c
{
  top.ast = decllist_list(decl.ast, list.ast);
}

concrete production decl_c_module
top::Decl_c ::= 'mod' id::ID_t LCurly_t list::DeclList_c RCurly_t
{
  top.ast = decl_module(id, list.ast);
}

concrete production decl_c_import
top::Decl_c ::= 'imp' qid::Qid_c
{
  top.ast = decl_import(qid.ast);
}

concrete production decl_c_define
top::Decl_c ::= 'def' bnd::Bind_c
{
  top.ast = decl_define(bnd.ast);
}


-- Not included in the grammar given in the publication - but seems necessary for the examples given.
concrete production decl_c_exp
top::Decl_c ::= exp::Exp_c
{
  top.ast = decl_exp(exp.ast);
}

concrete production qid_c_single
top::Qid_c ::= id::ID_t
{
  top.ast = qid_single(id);
}

concrete production qid_c_list
top::Qid_c ::= id::ID_t ',' qid::Qid_c
{
  top.ast = qid_list(id, qid.ast);
}

concrete production bindlist_c_single
top::BindList_c ::= bnd::Bind_c
{
  top.ast = bindlist_single(bnd.ast);
}

concrete production bindlist_c_list
top::BindList_c ::= bnd::Bind_c list::BindList_c
{
  top.ast = bindlist_list(bnd.ast, list.ast);
}

concrete production bind_c
top::Bind_c ::= id::ID_t '=' exp::Exp_c
{
  top.ast = bnd(id, exp.ast);
}

concrete production bind_c_decl
top::Bind_c ::= id::ID_t
{
  top.ast = bnd_decl(id);
}

-- expressions

concrete production exp_c_plus
top::Exp_c ::= expLeft::Exp_c Plus_t expRight::Exp_c
{
  top.ast = exp_plus(expLeft.ast, expRight.ast);
}

concrete production exp_c_app
top::Exp_c ::= expLeft::Exp_c App_t expRight::Exp_c
{
  top.ast = exp_app(expLeft.ast, expRight.ast);
}

concrete production exp_c_qid
top::Exp_c ::= qid::Qid_c 
{
  top.ast = exp_qid(qid.ast);
}

concrete production exp_c_fun
top::Exp_c ::= 'fun' id::ID_t LCurly_t exp::Exp_c RCurly_t 
{
  top.ast = exp_fun(id, exp.ast);
}

concrete production exp_c_let
top::Exp_c ::= 'let' list::BindList_c 'in' exp::Exp_c
{
  top.ast = exp_let(list.ast, exp.ast);
}

concrete production exp_c_letrec
top::Exp_c ::= 'letrec' list::BindList_c 'in' exp::Exp_c
{
  top.ast = exp_letrec(list.ast, exp.ast);
}

concrete production exp_c_letpar
top::Exp_c ::= 'letpar' list::BindList_c 'in' exp::Exp_c
{
  top.ast = exp_letpar(list.ast, exp.ast);
}

concrete production exp_c_int
top::Exp_c ::= val::Int_t
{
  top.ast = exp_int(val);
}
