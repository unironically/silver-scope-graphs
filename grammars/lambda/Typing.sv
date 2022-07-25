-- Type Representations
production arrow
t::Type ::= t1::Type t2::Type
{
 t.pp = pp"(${t1.pp} -> ${t2.pp})";
}

production int
t::Type ::=
{
 t.pp = pp"int";
}

-- Typing functions --
function lookup_type
Typing ::= s::String id::Decorated IdRef env::[(String, Type)]
{
  return 
    case env of
    | [] -> type_errs( [ id_not_declared (id) ] )
    | (nm, t) :: rest ->
        if nm == s
        then typed(t)
        else lookup_type (s, id, rest)
    end;
}

function eqType
Boolean ::= t1::Type t2::Type
{
 return
   case t1, t2 of
   | arrow(ta, tb), arrow(tc, td) -> eqType(ta, tc) && eqType(tb, td) 
   | int(), int() -> true
   | _, _ -> false
   end;
}

nonterminal Typing ;
production typed
ty::Typing ::= t::Type
{
}

production type_errs
ty::Typing ::= msg:: [Error]
{ 
}

function any_errors
[Error] ::= ty::Typing
{ return
    case ty of
    | typed (_) -> []
    | type_errs (errs) -> errs
   end;
}

function ensure_both_int_type
Typing ::= l::Decorated Expr  r::Decorated Expr
{ return
    case l.typing, r.typing of
    | typed (int ()), typed (int ()) -> typed (int ())
    | lty, rty ->
        type_errs (any_errors (ensure_int_type (l)) ++
                   any_errors (ensure_int_type (r))
                  )
        -- Since at least one of l and r are not integer expressions at least
        -- one of the lists from any_errors will be non empty.
    end;
}

function ensure_int_type
Typing ::= e::Decorated Expr
{ return
    case e.typing of
    | typed (int ()) -> typed (int ())
    | typed (t) -> type_errs ( [ int_type_expected (e) ] )
    | errs -> errs
    end;
}

nonterminal Error;
synthesized attribute msg :: String occurs on Error;

production let_type_mismatch
err::Error ::= let_::Decorated Expr
-- invariant let_ matches let_expr(_, _, _, _)
{ err.msg = "let error";
}

production fun_arg_type_mismatch
err::Error ::= app_::Decorated Expr
-- invariant app_ matches app_expr (_, _)
{ err.msg = "fun arg mismatch error";
}

production fun_type_expected
err::Error ::= f::Decorated Expr
{ err.msg = "Error: " ++ f.location.unparse ++ "\n   " ++
    "Expected a functional type, but found " ++ 
    case f.typing of
    | typed (t) -> show(80, t.pp)
    | type_errs (_) -> "a already erroneous expressions."
    end;
}

production int_type_expected
err::Error ::= f::Decorated Expr
{ err.msg = "int type expected error";
}

production id_not_declared
err::Error ::= id::Decorated IdRef
{ err.msg = "Error: " ++ id.location.unparse ++ "\n   " ++
     "Identifier \"" ++ id.str_name ++ "\" not declared.";
}


