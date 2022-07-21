grammar lambda;

nonterminal Root       with pp, type, errors;
nonterminal Expr       with pp, type, env, errors;
nonterminal Type       with pp;

-- Strings used to hold informational error messages
synthesized attribute errors :: [String];

-- Holds type description
synthesized attribute type :: Type;

-- List of pairs to hold variables and their type
inherited attribute env :: [Pair<String Type>];


-- Root
abstract production root
p::Root ::= e::Expr
{
 p.pp = e.pp;

 e.env = [];
 p.type = e.type;
 p.errors = e.errors;
}


-- Expr
abstract production expr_let
e::Expr ::= id::String t::Type e1::Expr e2::Expr
{
 e.pp = pp"(let ${text(id)} : ${t.pp} = ${e1.pp} in ${e2.pp})";

 e1.env = e.env;
 e2.env = (id, t) :: e.env;

 e.type = e2.type;

 local attribute synErrors :: [String];
 synErrors = e1.errors ++ e2.errors;

 e.errors = if !eqType(e1.type, t)
            then ("Declaration type and definition are mismatched\n" 
              ++ "\tDecl:" ++ show(80,t.pp) ++ "\n"
              ++ "\tDef :" ++ show(80,e1.type.pp) ++ "\n")
              :: synErrors
            else synErrors;
}

abstract production expr_lambda
e::Expr ::= id::String tl::Type e1::Expr
{
 e.pp = pp"(lambda ${text(id)}:${tl.pp}.${e1.pp})";
 e.type = arrow(tl, e1.type);

 e1.env = [pair(id, tl)] ++ e.env;

 e.errors = case tl of
              type_err() -> [id ++ " is type_err"]
            | _ -> []
            end ++ 
            case e1.type of
              type_err() -> [show(80,e1.pp) ++ " is type_err"]
            | _ -> []
            end ++ e1.errors;
}


-- Expr_funct
abstract production expr_app
mp::Expr ::= mp1::Expr e::Expr
{
 local attribute synErrors :: [String];
 synErrors = mp1.errors ++ e.errors;

 mp.pp = pp"(${mp1.pp} ${e.pp})";
 mp.type = case mp1.type of
             arrow(ta, tb) -> tb
           | int() -> type_err()
           | type_err() -> type_err()
           end ;

 mp1.env = mp.env;
 e.env = mp.env;

 mp.errors = case mp1.type of
               arrow(ta, tb) -> if !eqType(ta, e.type)
                                then ("Incompatible types\n"
                                  ++ "\tMethod:" ++ show(80,mp1.type.pp) ++ "\n"
                                  ++ "\tInput :" ++ show(80,e.type.pp) ++ "\n")
                                  :: synErrors
                                else synErrors
             | int() -> ["Incompatible types\n"
                     ++ "\tMethod:int\n"
                     ++ "\tInput :" ++ show(80,e.type.pp)]
                     ++ synErrors
             | type_err() -> ["Error already exists\n"] ++ synErrors
             end;
}

{-
abstract production methodpassing_ex
mp::Expr_funct ::= e::Expr_arith
{
 mp.pp = e.pp;
 mp.type = e.type;

 e.env = mp.env;

 mp.errors = e.errors;
}
-}

-- Expr_arith
abstract production expr_add
e::Expr ::= e1::Expr t::Expr
{
 local attribute synErrors :: [String];
 synErrors = e1.errors ++ t.errors;

 e.pp = pp"(${e1.pp}+${t.pp})";
 e.type = int();

 e1.env = e.env;
 t.env = e.env;

 e.errors = if !eqType(e1.type, int())
            then ["Invalid argument for binary operator:\n"
              ++ "\t" ++ show(80,e1.type.pp)]
              ++ synErrors
            else
              if !eqType(t.type, int())
              then ["Invalid argument for binary operator:\n"
                ++ "\t" ++ show(80,t.type.pp)]
                ++ synErrors
              else synErrors;
}

abstract production expr_sub
e::Expr ::= e1::Expr t::Expr
{
 e.pp = pp")${e1.pp}-${t.pp})";

 -- All other functionality is identical to expr_add
 forwards to expr_add(e1, t);
}

{-
abstract production expr_term
e::Expr ::= t::Term
{
 e.pp = t.pp;
 e.type = t.type;

 t.env = e.env;

 e.errors = t.errors;
}
-}

-- Term
abstract production term_mul
t::Expr ::= t1::Expr f::Expr
{
 local attribute synErrors :: [String];
 synErrors = t1.errors ++ f.errors;

 t.pp = pp"(${t1.pp} * ${f.pp})";
 t.type = int();

 t1.env = t.env;
 f.env = t.env;

 t.errors = if !eqType(t1.type, int())
            then ["Incompatible parameter for binary operator\n"
              ++ "\t" ++ show(80,t1.type.pp)]
              ++ synErrors
            else
              if !eqType(f.type, int()) 
              then ["Incompatible parameter for binary operator\n"
                ++ "\t" ++ show(80,f.type.pp)]
                ++ synErrors
              else synErrors;
}

abstract production term_div
t::Expr ::= t1::Expr f::Expr
{
 t.pp = pp"(${t1.pp} / ${f.pp})";

 -- All other functionality is identical to term_mul
 forwards to term_mul(t1,f);
}

{-
abstract production term_factor
t::Term ::= f::Factor
{
 t.pp = f.pp;
 t.type = f.type;

 f.env = t.env;

 t.errors = f.errors;
}
-}

-- Factor
abstract production factor_id
f::Expr ::= id::String
{
 f.pp = text(id);
 f.type = lookup_type(id, f.env);

 f.errors = case f.type of
            | type_err() -> ["Identifier \"" ++ id ++ "\" not declared."]
            | _ -> []
            end;
}

abstract production factor_int
f::Expr ::= num::String
{
 f.pp = text(num);
 f.type = int();

 f.errors = if !isDigit(num)
            then ["Not an integer: " ++ num]
            else [];
}

-- Type
abstract production arrow
t::Type ::= t1::Type t2::Type
{
 t.pp = pp"(${t1.pp} -> ${t2.pp})";
}

abstract production int
t::Type ::=
{
 t.pp = pp"int";
}

abstract production type_err
t::Type ::=
{
 t.pp = pp"TYPE ERROR";
}


-- Binding functions --

function lookup_type
Type ::= s::String env::[Pair<String Type>]
{
  return 
    case env of
    | [] -> type_err()
    | (nm, typ) :: rest ->
        if nm == s
        then typ
        else lookup_type (s, rest)
    end;
}

function eqType
Boolean ::= t1::Type t2::Type
{
 return
   case t1, t2 of
   | arrow(ta, tb), arrow(tc, td) -> eqType(ta, tc) && eqType(tb, td) 
   | int(), int() -> true
   | _ -> false
   end;
}
