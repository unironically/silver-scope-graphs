grammar lambda;

nonterminal Root with pp, typing, location;
nonterminal Expr with pp, typing, env, location;
nonterminal TypeExpr with pp, typerep, location;

nonterminal Type with pp;

synthesized attribute typing :: Typing;

synthesized attribute typerep :: Type;

inherited attribute env :: [ (String, Type) ];

-- Root
production root
r::Root ::= e::Expr
{
 r.pp = e.pp;
 e.env = [];
 r.typing = e.typing;
}


-- Expr
production let_expr
e::Expr ::= id::String t::TypeExpr e1::Expr e2::Expr
{
 e.pp = pp"(let ${text(id)} : ${t.pp} = ${e1.pp} in ${e2.pp})";

 e1.env = e.env;
 e2.env = (id, t.typerep) :: e.env;

 e.typing = case e1.typing of
            | typed (t1) ->
                if eqType(t1, t.typerep)
                then e2.typing 
                else type_errs ( [ let_type_mismatch(e) ] )
            | errs -> errs
            end;
}

-- Lambda Expression
production lambda_expr
e::Expr ::= id::String t::TypeExpr body::Expr
{
 e.pp = pp"(lambda ${text(id)} : ${t.pp} . ${body.pp})";

 body.env = (id, t.typerep) :: e.env;

 e.typing = case body.typing of
            | typed(ty) -> typed (arrow (t.typerep, ty) )
            | errs -> errs
            end;
}

-- Function Application
production app_expr
e::Expr ::= fun::Expr arg::Expr
{
 e.pp = pp"(${fun.pp} ${arg.pp})";

 fun.env = e.env;
 arg.env = e.env;

 e.typing = case fun.typing of
   | typed (arrow (tin, tout)) ->
       case arg.typing of
       | typed (t) ->
           if eqType (tin, t) 
           then typed (tout)
           else type_errs ( [ fun_arg_type_mismatch (e) ] )
       | errs -> errs
       end
   | typed (_) ->
       type_errs ( fun_type_expected (fun) :: any_errors (arg.typing) )
   | type_errs (errs) -> type_errs (errs ++ any_errors (arg.typing))
   end;
}

-- Arrithmetic Expresssions
production add_expr
e::Expr ::= l::Expr r::Expr
{
 e.pp = pp"(${l.pp} + ${r.pp})";

 l.env = e.env;
 r.env = e.env;

 e.typing = ensure_both_int_type (l, r);
}

production sub_expr
e::Expr ::= l::Expr r::Expr
{
 e.pp = pp"(${l.pp} - ${r.pp})";

 l.env = e.env;
 r.env = e.env;

 e.typing = ensure_both_int_type (l, r);
}

production mul_expr
e::Expr ::= l::Expr r::Expr
{
 e.pp = pp"(${l.pp} * ${r.pp})";

 l.env = e.env;
 r.env = e.env;

 e.typing = ensure_both_int_type (l, r);
}

production div_expr
e::Expr ::= l::Expr r::Expr
{
 e.pp = pp"(${l.pp} / ${r.pp})";

 l.env = e.env;
 r.env = e.env;

 e.typing = ensure_both_int_type (l, r);
}

-- Identifier Reference
production id_ref
e::Expr ::= id::String
{
 e.pp = text(id);
 e.typing = lookup_type(id, e, e.env);
}

-- Integer Constant
production int_const
e::Expr ::= num::Integer
{
 e.pp = text (toString (num));
 e.typing = typed (int ());
}

-- Type Expressions
production arrow_te
t::TypeExpr ::= t1::TypeExpr t2::TypeExpr
{
 t.pp = pp"(${t1.pp} -> ${t2.pp})";
 t.typerep = arrow (t1.typerep, t2.typerep);
}

production int_te
t::TypeExpr ::=
{
 t.pp = pp"int";
 t.typerep = int ();
}

