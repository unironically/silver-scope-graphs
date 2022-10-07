grammar lmlang_full_list;

inherited attribute env::[Decorated lm:IdDecl] occurs on lm:Program, lm:DeclList, lm:Decl, lm:Qid, lm:Exp, 
  lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdDecl, lm:IdRef;

synthesized attribute pass_env::[Decorated lm:IdDecl] occurs on lm:Decl, lm:DeclList, lm:BindListSeq, 
  lm:BindListRec, lm:BindListPar, lm:IdDecl;

synthesized attribute myDecl::Decorated lm:IdDecl occurs on lm:IdRef;

synthesized attribute name::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute str::String occurs on lm:IdDecl, lm:IdRef;
synthesized attribute line::Integer occurs on lm:IdDecl, lm:IdRef;
synthesized attribute column::Integer occurs on lm:IdDecl, lm:IdRef;

monoid attribute bindings::[(lm:IdRef, Decorated lm:IdDecl)] occurs on lm:Program, lm:DeclList, 
  lm:Decl, lm:Qid, lm:Exp, lm:BindListSeq, lm:BindListRec, lm:BindListPar, lm:IdRef;

inherited attribute type::Type occurs on lm:IdDecl;
synthesized attribute ref_type::Type occurs on lm:IdRef;
synthesized attribute exp_type::Type occurs on lm:Exp;
synthesized attribute qid_type::Type occurs on lm:Qid;
synthesized attribute import_env::[Decorated lm:IdDecl] occurs on lm:Qid, lm:IdRef;

{-
def a = 0 def b = 1 def c = 2 letseq a = c  b = a  c = b in a + b + c
    4         14        24           37  41 43  47 49  53   58  62  66    

def a = 0 def b = 1 def c = 2 letpar a = c  b = a  c = b in a + b + c
    4         14        24           37  41 43  47 49  53   58  62  66    

def a = 0 def b = 1 def c = 2 letrec a = c  b = a  c = b in a + b + c
    4         14        24           37  41 43  47 49  53   58  62  66                
-}

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

  top.pass_env = decl.env ++ list.pass_env;
}

aspect production lm:decllist_nothing
top::lm:DeclList ::=
{
  propagate bindings;

  top.pass_env = [];
}

------------------------------------------------------------
---- Decls
------------------------------------------------------------

aspect production lm:decl_module
top::lm:Decl ::= decl::lm:IdDecl list::lm:DeclList
{
  decl.env = top.env;
  list.env = decl.pass_env;

  top.bindings := list.bindings;
  top.pass_env = decl.pass_env ++ list.pass_env;

  -- Type
  decl.type = module_type(list.pass_env);
}

aspect production lm:decl_import
top::lm:Decl ::= qid::lm:Qid
{
  qid.env = top.env;

  top.bindings := [];
  top.pass_env = qid.import_env;
}

aspect production lm:decl_def
top::lm:Decl ::= decl::lm:IdDecl exp::lm:Exp
{
  propagate bindings;

  decl.env = top.env;
  exp.env = decl.pass_env ++ top.env;

  top.pass_env = decl.pass_env;

  -- Type
  decl.type = exp.exp_type;
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

  -- type
  top.exp_type = exp.exp_type;
}

aspect production lm:bindlist_list_seq
top::lm:BindListSeq ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListSeq
{
  propagate bindings;

  decl.env = top.env;
  exp.env = top.env;
  list.env = decl.pass_env ++ top.env;

  top.pass_env = list.pass_env ++ decl.pass_env;

  -- type 
  decl.type = exp.exp_type;
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

  -- type
  top.exp_type = exp.exp_type;
}

aspect production lm:bindlist_list_rec
top::lm:BindListRec ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListRec
{
  propagate bindings;

  decl.env = list.pass_env ++ top.env;
  exp.env = decl.pass_env ++ list.pass_env ++ top.env;
  list.env = decl.pass_env ++ top.env;

  top.pass_env = decl.pass_env ++ list.pass_env;  

  -- type 
  decl.type = exp.exp_type;
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

  -- type
  top.exp_type = exp.exp_type;
}

aspect production lm:bindlist_list_par
top::lm:BindListPar ::= decl::lm:IdDecl exp::lm:Exp list::lm:BindListPar
{
  propagate bindings;

  decl.env = top.env;
  exp.env = top.env;
  list.env = top.env;

  top.pass_env = decl.pass_env ++ list.pass_env;

  -- type 
  decl.type = exp.exp_type;
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

  -- type 
  decl.type = exp.exp_type;
}

aspect production lm:exp_add
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate bindings;

  left.env = top.env;
  right.env = top.env;

  -- type
  -- todo: type checking here
  top.exp_type = int_type();
}

aspect production lm:exp_app
top::lm:Exp ::= left::lm:Exp right::lm:Exp
{
  propagate bindings;

  left.env = top.env;
  right.env = top.env;

  -- type
  -- todo: type checking here
  top.exp_type = left.exp_type;
}

aspect production lm:exp_qid
top::lm:Exp ::= qid::lm:Qid
{
  propagate bindings;

  qid.env = top.env;

  -- type
  top.exp_type = qid.qid_type;
}

aspect production lm:exp_int
top::lm:Exp ::= val::lm:Int_t
{
  propagate bindings;

  -- type
  top.exp_type = int_type();
}

aspect production lm:exp_bool
top::lm:Exp ::= val::Boolean
{
  propagate bindings;

  -- type
  top.exp_type = bool_type();
}

------------------------------------------------------------
---- Qualified identifiers
------------------------------------------------------------

aspect production lm:qid_dot
top::lm:Qid ::= ref::lm:IdRef qid::lm:Qid
{
  propagate bindings;

  ref.env = top.env;
  qid.env = ref.import_env ++ top.env;

  top.import_env = qid.import_env;

  -- type
  top.qid_type = qid.qid_type;
}

aspect production lm:qid_single
top::lm:Qid ::= ref::lm:IdRef
{
  propagate bindings;

  ref.env = top.env;

  top.import_env = ref.import_env;

  -- type
  top.qid_type = ref.ref_type;
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
  top.bindings := [(top, top.myDecl)];

  top.myDecl = head(
    filterMap(
      (\cur::Decorated lm:IdDecl -> 
        if cur.name == top.name then just(cur) else nothing()),
        let e::[Decorated lm:IdDecl] = top.env in 
          unsafeTrace(e, printT("looking for: " ++ top.name ++ " with env: {" ++ foldl((\acc::String d::Decorated lm:IdDecl -> 
            acc ++ "," ++ d.str), "", e) ++ "}\n", unsafeIO())) end
    )
  );

  -- type
  top.ref_type = top.myDecl.type;
  top.import_env = top.myDecl.type.decls;
}