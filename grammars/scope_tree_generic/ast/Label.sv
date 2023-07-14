grammar scope_tree_generic:ast;

{- Global label initialization -}
global mod_lab :: Label = mod_prod ([]);
global var_lab :: Label = var_prod ([]);
global rec_lab :: Label = rec_prod ([]);
global ext_lab :: Label = ext_prod ([mod_lab, var_lab, rec_lab]);
global imp_lab :: Label = imp_prod ([mod_lab, var_lab, rec_lab]);
global lex_lab :: Label = lex_prod ([mod_lab, var_lab, rec_lab, ext_lab, imp_lab]);

{- Labels -}

nonterminal Label;

synthesized attribute is_lt :: (Boolean ::= Label) occurs on Label;

abstract production lex_prod
top::Label ::= greater::[Label]
{ top.is_lt = \x::Label -> label_is_lt (x, greater); }

abstract production ext_prod
top::Label ::= greater::[Label]
{ top.is_lt = \x::Label -> label_is_lt (x, greater); }

abstract production var_prod
top::Label ::= greater::[Label]
{ top.is_lt = \x::Label -> label_is_lt (x, greater); }

abstract production imp_prod
top::Label ::= greater::[Label]
{ top.is_lt = \x::Label -> label_is_lt (x, greater); }

abstract production mod_prod
top::Label ::= greater::[Label]
{ top.is_lt = \x::Label -> label_is_lt (x, greater); }

abstract production rec_prod
top::Label ::= greater::[Label]
{ top.is_lt = \x::Label -> label_is_lt (x, greater); }

function label_is_lt
Boolean ::= l1::Label lst::[Label]
{ return ! containsBy (label_eq, l1, lst); }

function label_eq
Boolean ::= l1::Label l2::Label
{
  return
    case (l1, l2) of
      (lex_prod (_), lex_prod (_)) -> true
    | (ext_prod (_), ext_prod (_)) -> true
    | (var_prod (_), var_prod (_)) -> true
    | (imp_prod (_), imp_prod (_)) -> true
    | (mod_prod (_), mod_prod (_)) -> true
    | (rec_prod (_), rec_prod (_)) -> true
    | _                            -> false
    end;
}

{- Regular expressions -}

nonterminal Regex;
synthesized attribute nfa :: NFA occurs on Regex;

abstract production concatenate
top::Regex ::= r1::Regex r2::Regex
{
  top.nfa = nfa_concatenate (r1.nfa, r2.nfa);
}

abstract production star
top::Regex ::= r1::Regex
{
  top.nfa = nfa_star (r1.nfa);
}

abstract production alternate
top::Regex ::= r1::Regex r2::Regex
{
  top.nfa = nfa_alternate (r1.nfa, r2.nfa);
}

abstract production single
top::Regex ::= label::Label
{
  top.nfa = nfa_single (label);
}