grammar lambda;

nonterminal Root with pp, typing, location;
nonterminal Expr with pp, typing, env, location;
nonterminal IdDcl with pp, str_name, location;
nonterminal IdRef with pp, str_name, location;
nonterminal TypeExpr with pp, typerep, location;

nonterminal Type with pp;

-- type or type errors
synthesized attribute typing :: Typing;

-- a representation for types
synthesized attribute typerep :: Type;

synthesized attribute str_name :: String;

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
e::Expr ::= id::IdDcl t::TypeExpr e1::Expr e2::Expr
{
 e.pp = pp"(let ${id.pp} : ${t.pp} = ${e1.pp} in ${e2.pp})";

 e1.env = e.env;
 e2.env = (id.str_name, t.typerep) :: e.env;

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
e::Expr ::= id::IdDcl t::TypeExpr body::Expr
{
 e.pp = pp"(lambda ${id.pp} : ${t.pp} . ${body.pp})";

 body.env = (id.str_name, t.typerep) :: e.env;

 e.typing = case body.typing of
            | typed(ty) -> typed (arrow (t.typerep, ty) )
            | errs -> errs
            end;
}

production id_dcl
id::IdDcl ::= nm::String
{
  id.pp = text(nm);
  id.str_name = nm;
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
production ident
e::Expr ::= id::IdRef
{
 e.pp = id.pp;
 e.typing = lookup_type(id.str_name, id, e.env);
}

-- Integer Constant
production int_const
e::Expr ::= num::Integer
{
 e.pp = text (toString (num));
 e.typing = typed (int ());
}

-- Identifier
production id_ref
i::IdRef ::= nm::String
{
  i.pp = text(nm);
  i.str_name = nm;
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

