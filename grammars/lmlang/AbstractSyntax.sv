grammar lmlang;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindList;
nonterminal Bind;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, BindList, Bind;

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
  local attribute new_scope::Scope = construct_scope(nothing(), []);
  new_scope.references = [];
  list.current_scope = new_scope;
  top.scope_list = appendList([new_scope], list.scope_list);
}

abstract production decllist_single
top::DeclList ::= decl::Decl
{
  top.pp = "decllist_single(" ++ decl.pp ++ ")";
  decl.current_scope = top.current_scope;
  top.scope_list = decl.scope_list;
}

abstract production decllist_list
top::DeclList ::= decl::Decl list::DeclList
{
  top.pp = "decl_list(" ++ decl.pp ++ ", " ++ list.pp ++ ")";
}

abstract production decl_module
top::Decl ::= id::ID_t list::DeclList
{
  top.pp = "module(" ++ id.lexeme ++ ", " ++ list.pp ++ ")";
}

abstract production decl_import
top::Decl ::= qid::Qid
{
  top.pp = "import(" ++ qid.pp ++ ")";
}

abstract production decl_define
top::Decl ::= bnd::Bind
{
  top.pp = "define(" ++ bnd.pp ++ ")";
}

-- Not included in the grammar given in the publication - but seems necessary for the examples given.
abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
  exp.current_scope = top.current_scope;
  top.scope_list = exp.scope_list;
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
  local attribute curr::Scope = top.current_scope;
  curr.references = top::curr.references;  
  top.scope_list = [];
}

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "qid_list(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

abstract production bindlist_single
top::BindList ::= bnd::Bind
{
  top.pp = "bndlist_single(" ++ bnd.pp ++ ")";
  bnd.current_scope = top.current_scope;
  top.scope_list = bnd.scope_list;
  top.result_scope = bnd.result_scope;
}

abstract production bindlist_list
top::BindList ::= bnd::Bind list::BindList
{
  top.pp = "bindlist_list(" ++ bnd.pp ++ ", " ++ list.pp ++ ")";
  bnd.current_scope = top.current_scope;
  list.current_scope = bnd.result_scope;
  top.scope_list = appendList(bnd.scope_list, list.scope_list);
}

abstract production bnd
top::Bind ::= id::ID_t exp::Exp
{
  top.pp = "bind(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
  exp.current_scope = top.current_scope;
  local attribute new_scope::Scope = construct_scope(just(top.current_scope), [top]);
  new_scope.references = [];
  top.scope_list = [new_scope];
  top.result_scope = new_scope;
}

abstract production bnd_decl
top::Bind ::= id::ID_t
{
  top.pp = "decl(" ++ id.lexeme ++ ")";
}

abstract production exp_plus
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "plus(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
}

abstract production exp_app
top::Exp ::= expLeft::Exp expRight::Exp
{
  top.pp = "apply(" ++ expLeft.pp ++ ", " ++ expRight.pp ++ ")";
}

abstract production exp_qid
top::Exp ::= qid::Qid
{
  top.pp = "exp_qid(" ++ qid.pp ++ ")";
  qid.current_scope = top.current_scope;
  top.scope_list = qid.scope_list;
}

abstract production exp_fun
top::Exp ::= id::ID_t exp::Exp
{
  top.pp = "fun(" ++ id.lexeme ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_let
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "exp_let(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
  list.current_scope = top.current_scope;
  local attribute ret_scope::Scope = list.result_scope;
  exp.current_scope = ret_scope;
  top.scope_list = appendList(list.scope_list, exp.scope_list);
}

abstract production exp_letrec
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "exp_letrec(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_letpar
top::Exp ::= list::BindList exp::Exp
{
  top.pp = "exp_letpar(" ++ list.pp ++ ", " ++ exp.pp ++ ")";
}

abstract production exp_int
top::Exp ::= val::Int_t
{
  top.pp = "exp_int(" ++ val.lexeme ++ ")";
}

-- Scope graph things

inherited attribute current_scope :: Scope occurs on Program, DeclList, Decl, Qid, Exp, BindList, Bind;
synthesized attribute result_scope :: Scope occurs on Program, DeclList, Decl, Qid, Exp, BindList, Bind;
synthesized attribute scope_list :: [Decorated Scope] occurs on Program, DeclList, Decl, Qid, Exp, BindList, Bind;

synthesized attribute id :: Integer occurs on Scope;
synthesized attribute parent :: Maybe<Scope>;
inherited attribute references :: [Decorated Qid];
synthesized attribute declarations :: [Decorated Bind];
synthesized attribute graphpp :: String occurs on Scope;

nonterminal Scope with parent, references, declarations;
abstract production construct_scope
top::Scope ::= par::Maybe<Scope> decls::[Decorated Bind]
{
  top.id = genInt();
  top.parent = par;
  top.declarations = decls;
  top.graphpp = "Scope(" ++ toString(top.id) ++ ", " ++ (case top.parent of just(x) -> toString(x.id) | nothing() -> "-" end) ++ ", " ++ print_refs(top.references) ++ ", " ++ print_decls(top.declarations) ++ ")";
}

function print_scopes
String ::= scope_list::[Decorated Scope]
{
  local attribute prints::String = case scope_list of
    | [] -> ""
    | h::t -> h.graphpp ++ ", " ++ print_scopes(t)
  end;
  return prints;
}

-- How to fix the below code smell(s) in Silver?

function print_refs
String ::= list::[Decorated Qid]
{
  local attribute prints::String = case list of
    | [] -> ""
    | h::t -> h.pp ++ ", " ++ print_refs(t)
  end;
  return "{" ++ prints ++ "}";
}

function print_decls
String ::= list::[Decorated Bind]
{
  local attribute prints::String = case list of
    | [] -> ""
    | h::t -> h.pp ++ ", " ++ print_decls(t)
  end;
  return "{" ++ prints ++ "}";
}
