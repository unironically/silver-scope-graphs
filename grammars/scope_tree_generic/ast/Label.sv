grammar scope_tree_generic:ast;

{- Global label initialization -}

global mod_lab :: Label = mod_prod ();
global var_lab :: Label = var_prod ();
global rec_lab :: Label = rec_prod ();
global ext_lab :: Label = ext_prod ();
global imp_lab :: Label = imp_prod ();
global lex_lab :: Label = lex_prod ();
global fld_lab :: Label = fld_prod ();

{- Global label order -}

-- Equivalence classes of labels, in preference order
global label_ord :: [[Label]] = [
  [mod_lab, var_lab, rec_lab, fld_lab],
  [ext_lab, imp_lab],
  [lex_lab]
];

-- Label order relation
global label_relation :: [(Label, Label)] = [
  (mod_lab, lex_lab), (mod_lab, imp_lab), (mod_lab, ext_lab),
  (rec_lab, lex_lab), (rec_lab, imp_lab), (rec_lab, ext_lab),
  (var_lab, lex_lab), (var_lab, imp_lab), (var_lab, ext_lab),
  (imp_lab, lex_lab), (ext_lab, lex_lab)
];

-- Label equality
function label_eq
Boolean ::= l1::Label l2::Label
{
  return
    case (l1, l2) of
      (lex_prod (), lex_prod ()) -> true
    | (ext_prod (), ext_prod ()) -> true
    | (var_prod (), var_prod ()) -> true
    | (imp_prod (), imp_prod ()) -> true
    | (mod_prod (), mod_prod ()) -> true
    | (rec_prod (), rec_prod ()) -> true
    | _                            -> false
    end;
}

{- Compares two labels.
 - Returns 0 if equal, -1 if l2 is preferred, 1 if l1 is preferred.
 -}
function label_comp
Integer ::=
  l1::Label
  l2::Label
{
  return foldl (
   (\comp::Integer pair::(Label, Label) -> 
     if label_eq(fst (pair), l1) && label_eq (snd (pair), l2)
      then 1
      else if label_eq(snd (pair), l1) && label_eq (fst (pair), l2)
             then -1 
             else comp
       
   ), 
   0, 
   label_relation
  );
}

{- Labels -}

nonterminal Label;
synthesized attribute lab_str :: String occurs on Label;

abstract production lex_prod
top::Label ::= { top.lab_str = "LEX"; }

abstract production ext_prod
top::Label ::= { top.lab_str = "EXT"; }

abstract production var_prod
top::Label ::= { top.lab_str = "VAR"; }

abstract production imp_prod
top::Label ::= { top.lab_str = "IMP"; }

abstract production mod_prod
top::Label ::= { top.lab_str = "MOD"; }

abstract production rec_prod
top::Label ::= { top.lab_str = "REC"; }

abstract production fld_prod
top::Label ::= { top.lab_str = "FLD"; }

{- Regular expressions -}

nonterminal Regex;
synthesized attribute nfa :: NFA occurs on Regex;
synthesized attribute dfa :: DFA occurs on Regex;

abstract production concatenate
top::Regex ::= r1::Regex r2::Regex
{ top.nfa = nfa_concatenate (r1.nfa, r2.nfa); 
  top.dfa = mk_dfa (top.nfa); }

abstract production star
top::Regex ::= r1::Regex
{ top.nfa = nfa_star (r1.nfa); 
  top.dfa = mk_dfa (top.nfa); }

abstract production alternate
top::Regex ::= r1::Regex r2::Regex
{ top.nfa = nfa_alternate (r1.nfa, r2.nfa); 
  top.dfa = mk_dfa (top.nfa); }

abstract production single
top::Regex ::= label::Label
{ top.nfa = nfa_single (label); 
  top.dfa = mk_dfa (top.nfa); }

abstract production maybe
top::Regex ::= r1::Regex
{ top.nfa = nfa_maybe (r1.nfa);
  top.dfa = mk_dfa (top.nfa);}

-- concatenate (star (lex_lab), single (var_lab))