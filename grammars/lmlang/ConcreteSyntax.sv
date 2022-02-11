grammar lmlang;

nonterminal Program_c;
nonterminal DeclList_c;
nonterminal Decl_c;
nonterminal Qid_c;
nonterminal Exp_c;
nonterminal BindList_c;
nonterminal Bind_c;

concrete production program_c
top::Program_c ::= DeclList_c
{}

concrete production decllist_c_single
top::DeclList_c ::= Decl_c
{}

concrete production decllist_c_list
top::DeclList_c ::= Decl_c DeclList_c
{}

concrete production decl_c_module
top::Decl_c ::= 'mod' id::ID_t LCurly_t dl::DeclList_c RCurly_t
{}

concrete production decl_c_import
top::Decl_c ::= 'imp' q::Qid_c
{}

concrete production decl_c_define
top::Decl_c ::= 'def' b::Bind_c
{}

concrete production qid_c_single
top::Qid_c ::= id::ID_t
{}

concrete production qid_c_list
top::Qid_c ::= id::ID_t ',' q::Qid_c
{}

concrete production bindlist_c_single
top::BindList_c ::= b::Bind_c
{}

concrete production bindlist_c_list
top::BindList_c ::= b::Bind_c bl::BindList_c
{}

concrete production bind_c
top::Bind_c ::= id::ID_t '=' e::Exp_c
{}

-- expressions

concrete production exp_c_plus
top::Exp_c ::= e1::Exp_c Plus_t e2::Exp_c
{}

concrete production exp_c_app
top::Exp_c ::= e1::Exp_c App_t e2::Exp_c
{}

concrete production exp_c_qid
top::Exp_c ::= q::Qid_c 
{}

concrete production exp_c_fun
top::Exp_c ::= 'fun' id::ID_t LCurly_t e::Exp_c RCurly_t 
{}

concrete production exp_c_let
top::Exp_c ::= 'let' bl::BindList_c 'in' e::Exp_c
{}

concrete production exp_c_letrec
top::Exp_c ::= 'letrec' bl::BindList_c 'in' e::Exp_c
{}

concrete production exp_c_letpar
top::Exp_c ::= 'letpar' bl::BindList_c 'in' e::Exp_c
{}

concrete production exp_c_int
top::Exp_c ::= i::Int_t
{}
