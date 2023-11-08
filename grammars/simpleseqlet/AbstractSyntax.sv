grammar simpleseqlet;

imports simpleseqlet:scopegraphs;

nonterminal Prog;
nonterminal Expr;

synthesized attribute ty::Type occurs on Prog, Expr;
synthesized attribute aterm::String occurs on Prog, Expr;

attribute simpleseqlet:scopegraphs:string occurs on Prog;

inherited attribute scope::Decorated Scope occurs on Expr;
propagate scope on Expr excluding letseq, letrec, letpar;

monoid attribute all_scopes::[Decorated Scope] with [], ++ occurs on Prog, Expr, BindListPar, BindListSeq, BindListRec;
propagate all_scopes on Expr, BindListPar, BindListSeq, BindListRec;

{- Program -}

abstract production prog
top::Prog ::= e::Expr
{
  propagate all_scopes;
  
  top.aterm = "Expr (" ++ e.aterm ++ ")";
  top.ty = e.ty;

  top.string = "digraph {" ++ implode (" ", map ((.string), top.all_scopes)) ++ "}";

  production attribute top_scope::Scope = mk_scope ([], [], [], [], [], [], []);
  e.scope = top_scope;

  top.all_scopes <- [top_scope];
}

{------------------}

{- Sequential let -}

abstract production letseq
top::Expr ::= bl::BindListSeq e::Expr
{
  local let_scope::Decorated Scope = bl.last_scope;

  bl.scope = top.scope;
  e.scope = let_scope;

  top.aterm = "Let ([" ++ bl.aterm ++ "], " ++ e.aterm ++ ")";

  top.ty = e.ty;
}

{- Binding list for let -}

synthesized attribute last_scope::Decorated Scope;

nonterminal BindListSeq with scope, aterm, last_scope;

abstract production bindlistseq_cons
top::BindListSeq ::= id::String e::Expr bl::BindListSeq
{
  local scopes::(Decorated Scope, Decorated Scope) = seqlet_scope (id, e, top.scope);

  local let_scope :: Decorated Scope = fst(scopes);
  local var_scope :: Decorated Scope = snd(scopes);

  bl.scope = let_scope;
  top.last_scope = bl.last_scope;
  e.scope = top.scope;

  top.aterm = "DefBind(\"" ++ id ++ "\", " ++ e.aterm ++ "), " ++ bl.aterm;

  top.all_scopes <- [let_scope, var_scope];
}

abstract production bindlistseq_one
top::BindListSeq ::= id::String e::Expr
{
  local scopes::(Decorated Scope, Decorated Scope) = seqlet_scope (id, e, top.scope);

  local let_scope :: Decorated Scope = fst(scopes);
  local var_scope :: Decorated Scope = snd(scopes);

  top.last_scope = let_scope;
  e.scope = top.scope;
  top.aterm = "DefBind(\"" ++ id ++ "\", " ++ e.aterm ++ ")";

  top.all_scopes <- [let_scope, var_scope];
}

function seqlet_scope
(Decorated Scope, Decorated Scope) ::= id::String e::Expr e_scope::Decorated Scope
{
  e.scope = e_scope;

  local var_scope::Scope = mk_scope_decl (datum_type(id, e.ty));
  local let_scope::Scope = mk_scope ([], [var_scope], [], [], [], [e_scope], []);

  return (let_scope, var_scope);
}






{------------------}

{- Recursive let -}

abstract production letrec
top::Expr ::= bl::BindListRec e::Expr
{
  local let_scope::Scope = mk_scope ([], bl.var_scopes, [], [], [], [top.scope], []);
  bl.scope = let_scope;
  e.scope = let_scope;

  top.ty = e.ty;

  top.aterm = "LetRec ([" ++ bl.aterm ++ "], " ++ e.aterm ++ ")";

  top.all_scopes <- [let_scope];
}

{- Binding list for let -}

synthesized attribute var_scopes::[Decorated Scope];

nonterminal BindListRec with scope, aterm, var_scopes;

abstract production bindlistrec_cons
top::BindListRec ::= id::String e::Expr bl::BindListRec
{
  local var_scope::Scope = mk_scope_decl (datum_type(id, e.ty));
  top.var_scopes = var_scope :: bl.var_scopes;
  e.scope = top.scope;
  bl.scope = top.scope;

  top.aterm = "DefBind(\"" ++ id ++ "\", " ++ e.aterm ++ "), " ++ bl.aterm;

  top.all_scopes <- [var_scope];
}

abstract production bindlistrec_one
top::BindListRec ::= id::String e::Expr
{
  local var_scope::Scope = mk_scope_decl (datum_type(id, e.ty));
  top.var_scopes = [var_scope];
  e.scope = top.scope;

  top.aterm = "DefBind(\"" ++ id ++ "\", " ++ e.aterm ++ ")";

  top.all_scopes <- [var_scope];
}






{------------------}

{- Parallel let -}

abstract production letpar
top::Expr ::= bl::BindListPar e::Expr
{
  local let_scope::Scope = mk_scope ([], bl.var_scopes, [], [], [], [top.scope], []);

  bl.scope = top.scope;
  e.scope = let_scope;

  top.ty = e.ty;
  top.aterm = "LetPar ([" ++ bl.aterm ++ "], " ++ e.aterm ++ ")";

  top.all_scopes <- [let_scope];
}

{- Binding list for let -}

nonterminal BindListPar with scope, var_scopes, aterm;

abstract production bindlistpar_cons
top::BindListPar ::= id::String e::Expr bl::BindListPar
{
  local var_scope::Scope = mk_scope_decl (datum_type(id, e.ty));
  
  bl.scope = top.scope;
  e.scope = top.scope;

  top.var_scopes = var_scope :: bl.var_scopes;
  top.aterm = "DefBind(\"" ++ id ++ "\", " ++ e.aterm ++ "), " ++ bl.aterm;

  top.all_scopes <- [var_scope];
}

abstract production bindlistpar_one
top::BindListPar ::= id::String e::Expr
{
  local var_scope::Scope = mk_scope_decl (datum_type(id, e.ty));

  e.scope = top.scope;

  top.var_scopes = [var_scope];
  top.aterm = "DefBind(\"" ++ id ++ "\", " ++ e.aterm ++ ")";

  top.all_scopes <- [var_scope];
}






{- ref -}

abstract production ref
top::Expr ::= id::String
{
  local q :: Query = mk_query (concatenate (
                                  star (single(lex_lab)),
                                  single(var_lab)),
                               top.scope,
                               same_id_check (id, _));

  top.ty = case head(q.results).tgt.datum of
             just(datum_type(s, t)) -> t
           | _ -> error("oh no!")
           end;

  top.aterm = "Ref(\"" ++ id ++ "\")";
}

{- Boolean arith -}

abstract production not
top::Expr ::= e1::Expr
{
  local e1Ty::Type = e1.ty;

  top.ty = case e1Ty of
             bool() -> bool()
           | _ -> bottom()
           end;

  top.aterm = "Not (" ++ e1.aterm ++ ")";
}

abstract production and
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (bool(), bool()) -> bool()
           | _ -> bottom()
           end;

  top.aterm = "And (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production or
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (bool(), bool()) -> bool()
           | _ -> bottom()
           end;

  top.aterm = "Or (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

{- Relational ops -}

abstract production lt
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;

  top.aterm = "Lt (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production gt
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;

  top.aterm = "Gt (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production leq
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;

  top.aterm = "Leq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production geq
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> bool()
           | _ -> bottom()
           end;

  top.aterm = "Geq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production equal
top::Expr ::= e1::Expr e2::Expr
{
  top.ty = if e1.ty == e2.ty
             then bool ()
             else bottom ();

  top.aterm = "Eq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production notequal
top::Expr ::= e1::Expr e2::Expr
{
  top.ty = if e1.ty == e2.ty
             then bool ()
             else bottom ();

  top.aterm = "Neq (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

{- Integer arith -}

abstract production mul
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.aterm = "Mul (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production div
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;
  
  top.aterm = "Div (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production add
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.aterm = "Add (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production sub
top::Expr ::= e1::Expr e2::Expr
{
  local e1Ty::Type = e1.ty;
  local e2Ty::Type = e2.ty;

  top.ty = case (e1Ty, e2Ty) of
             (int(), int()) -> int()
           | _ -> bottom()
           end;

  top.aterm = "Sub (" ++ e1.aterm ++ ", " ++ e2.aterm ++ ")";
}

abstract production neg
top::Expr ::= e1::Expr
{
  local e1Ty::Type = e1.ty;

  top.ty = case (e1Ty) of
             (int()) -> int()
           | _ -> bottom()
           end;

  top.aterm = "Neg (" ++ e1.aterm ++ ")";
}

{- Literals -}

abstract production intLit
top::Expr ::= i::Integer
{
  top.ty = int();
  top.aterm = "Int (\"" ++ toString(i) ++ "\")";
}

abstract production trueLit
top::Expr ::=
{
  top.ty = bool();
  top.aterm = "True ()";
}

abstract production falseLit
top::Expr ::=
{
  top.ty = bool();
  top.aterm = "False ()";
}