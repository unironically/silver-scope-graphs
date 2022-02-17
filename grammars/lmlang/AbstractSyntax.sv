grammar lmlang;

nonterminal Program;
nonterminal DeclList;
nonterminal Decl;
nonterminal Qid;
nonterminal Exp;
nonterminal BindList;
nonterminal Bind;

synthesized attribute pp::String occurs on Program, DeclList, Decl, Qid, Exp, BindList, Bind;

synthesized attribute final_scope::Scope occurs on Program;

abstract production prog 
top::Program ::= list::DeclList
{
  top.pp = "prog(" ++ list.pp ++ ")";
  local attribute first_scope::Scope = gen_scope(nothing());
  list.current_scope = first_scope;
  top.final_scope = first_scope;
}

abstract production decllist_single
top::DeclList ::= decl::Decl
{
  top.pp = "decllist_single(" ++ decl.pp ++ ")";
  decl.current_scope = top.current_scope;
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
top::Decl ::= id::ID_t exp::Exp
{
  top.pp = "define(" ++ id.lexeme ++ " = " ++ exp.pp ++ ")";
}

-- Not included in the grammar given in the publication - but seems necessary for the examples given.
abstract production decl_exp
top::Decl ::= exp::Exp
{
  top.pp = "decl_exp(" ++ exp.pp ++ ")";
  exp.current_scope = top.current_scope;
}

abstract production qid_single
top::Qid ::= id::ID_t
{
  top.pp = "qid_single(" ++ id.lexeme ++ ")";
  local attribute current::Scope = top.current_scope;
  current.references = top::current.references;
}

abstract production qid_list
top::Qid ::= id::ID_t qid::Qid
{
  top.pp = "qid_list(" ++ id.lexeme ++ ", " ++ qid.pp ++ ")";
}

abstract production bindlist_nothing
top::BindList ::=
{
  top.pp = ".";
  top.result_scope = nothing();
}

abstract production bindlist_list
top::BindList ::= id::ID_t exp::Exp list::BindList
{
  top.pp = "bindlist_list(" ++ id.lexeme ++ " = " ++ exp.pp ++ ", " ++ list.pp ++ ")";
  exp.current_scope = top.current_scope;
  local attribute current::Scope = top.current_scope;
  local attribute new_scope::Scope = gen_scope(just(top.current_scope));
  new_scope.declarations = [top];
  current.children = new_scope::current.children;
  list.current_scope = new_scope;
  top.result_scope = just(new_scope);
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
  local attribute new_scope::Scope = case list.result_scope of 
    | just(x) -> x 
    | nothing() -> error("Problem!")
  end;
  exp.current_scope = new_scope;
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

inherited attribute current_scope :: Scope occurs on DeclList, Decl, Qid, Exp, BindList;
synthesized attribute result_scope :: Maybe<Scope> occurs on BindList;

synthesized attribute id :: Integer;
synthesized attribute parent :: Maybe<Scope>;
synthesized attribute graphpp::String occurs on Scope;

inherited attribute children :: [Scope];
inherited attribute references :: [Decorated Qid];
inherited attribute declarations :: [Decorated BindList];

nonterminal Scope with id, parent, children, references, declarations;

abstract production construct_scope
top::Scope ::= par::Maybe<Scope>
{
  top.parent = par;
  top.graphpp = "Scope(" ++ 
    print_decls(top.declarations) ++ ", " ++
    print_refs(top.references) ++ ", " ++
    "{" ++ print_children(top.children) ++ "})"
  ;
}

-- How to fix the below code smell(s) in Silver?

function print_refs
String ::= list::[Decorated Qid]
{
  local attribute prints::String = case list of
    | [] -> ""
    | h::t -> h.pp ++ ", " ++ print_refs(t)
  end;
  return "references{" ++ prints ++ "}";
}

function print_decls
String ::= list::[Decorated BindList]
{
  local attribute prints::String = case list of
    | [] -> ""
    | h::t -> h.pp ++ ", " ++ print_decls(t)
  end;
  return "declarations{" ++ prints ++ "}";
}

function print_children
String ::= list::[Scope]
{
  local attribute prints::String = case list of
    | [] -> ""
    | h::t -> h.graphpp ++ ", " ++ print_children(t)
  end;
  return prints;
}

function gen_scope
Scope ::= parent::Maybe<Scope>
{
  local attribute new_scope::Scope = construct_scope(parent);
  new_scope.children = [];
  new_scope.references = [];
  new_scope.declarations = [];
  return new_scope;
}
