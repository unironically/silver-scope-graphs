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
synthesized attribute final_nfa :: Decorated NFA occurs on Regex;

abstract production regex
top::Regex ::= r1::Regex
{
  local my_nfa :: NFA = nfa (r1.nfa);
  my_nfa.used_id = 0;
  top.final_nfa = my_nfa;
}

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

{- NFAs -}

nonterminal NFA;
synthesized attribute start       :: Integer occurs on NFA;
synthesized attribute accepting   :: Integer occurs on NFA;
synthesized attribute transitions :: [(Integer, Maybe<Label>, Integer)] occurs on NFA;
inherited attribute used_id :: Integer occurs on NFA;
synthesized attribute took_id :: Integer occurs on NFA;

abstract production nfa
top::NFA ::= n1::NFA
{
  n1.used_id = 0;
  top.start = n1.start;
  top.accepting = n1.accepting;
  top.transitions = n1.transitions;
  top.took_id = n1.took_id;
}

abstract production nfa_concatenate
top::NFA ::= n1::NFA n2::NFA
{
  top.start = n1.start;
  top.accepting = n2.accepting;
  top.transitions = 
    (n1.accepting, nothing (), n2.start) :: n1.transitions ++ n2.transitions;
  n1.used_id = top.used_id;
  n2.used_id = n1.took_id;
  top.took_id = n2.took_id;
}

abstract production nfa_alternate
top::NFA ::= n1::NFA n2::NFA
{
  local state1 :: Integer = top.used_id + 1;
  local state2 :: Integer = top.used_id + 2;
  top.start = state1;
  top.accepting = state2;
  top.transitions = 
    (top.start, nothing (), n1.start) ::
    (top.start, nothing (), n2.start) ::
    (n1.accepting, nothing (), top.accepting) ::
    (n2.accepting, nothing (), top.accepting) ::
    n1.transitions ++
    n2.transitions;
  
  n1.used_id = top.used_id + 2;
  n2.used_id = n1.took_id;
  top.took_id = n2.took_id;
}

abstract production nfa_star
top::NFA ::= n1::NFA
{
  local state1 :: Integer = top.used_id + 1;
  local state2 :: Integer = top.used_id + 2;
  top.start = state1;
  top.accepting = state2;
  top.transitions = 
    (top.start, nothing (), n1.start) ::
    (top.start, nothing (), top.accepting) ::
    (n1.accepting, nothing (), n1.start) ::
    (n1.accepting, nothing (), top.accepting) ::
    n1.transitions;
  n1.used_id = top.used_id + 2;
  top.took_id = n1.took_id;
}

abstract production nfa_single
top::NFA ::= label::Label
{
  local state1 :: Integer = top.used_id + 1;
  local state2 :: Integer = top.used_id + 2;
  top.start = state1;
  top.accepting = state2;
  top.transitions =
    (top.start, just (label), top.accepting) :: [];
  top.took_id = top.used_id + 2;
}



function accepts
Boolean ::= nfa::Decorated NFA labs::[Label]
{
  local result :: [Integer] = steps (nfa, nfa.start, labs);

  return unsafeTrace (containsBy (state_eq (_, _, nfa), nfa.accepting, result), printT (
    "Got to: " ++ implode (" ", map ((\x::Integer -> toString (x)), result)) ++ "\n"
    , unsafeIO()));
}

function steps
[Integer] ::= nfa::Decorated NFA current::Integer labs::[Label]
{
  return
    case labs of
      [] -> [current]
    | l::ls -> 
        let 
          next :: [Integer] = step (nfa, current, l)
        in
          concat (map (steps (nfa, _, ls), next))
        end
    end;
}

function step
[Integer] ::= nfa::Decorated NFA s::Integer lab::Label
{


  local valid_steps :: [(Integer, Maybe<Label>, Integer)] =
    filter (\pair :: (Integer, Maybe<Label>, Integer) -> 
              state_eq (s, fst(pair), nfa) && valid_lab (lab, fst (snd (pair))), 
            nfa.transitions);
  

  local part :: ([(Integer, Maybe<Label>, Integer)], [(Integer, Maybe<Label>, Integer)]) =
    partition (is_eps_trans, unsafeTrace (valid_steps, printT ("Valid len: " ++ toString (length (valid_steps)) ++ "\n", unsafeIO())));
  

  local eps_trans :: [(Integer, Maybe<Label>, Integer)] = 
    unsafeTrace (fst (part), printT("Eps trans -> " ++ implode (" ", map ((\x::(Integer, Maybe<Label>, Integer) -> toString(fst(x))), fst(part))) ++ "\n", unsafeIO()));
  local eps_to :: [Integer] = 
    map ((\tup::(Integer, Maybe<Label>, Integer) -> snd (snd (tup))), eps_trans);


  local lab_trans :: [(Integer, Maybe<Label>, Integer)] = 
    unsafeTrace (snd (part), printT("Valid trans -> " ++ implode (" ", map ((\x::(Integer, Maybe<Label>, Integer) -> toString( snd(snd(x)) )), snd(part))) ++ "\n", unsafeIO()));

  local lab_to :: [Integer] = 
    map ((\tup::(Integer, Maybe<Label>, Integer) -> snd (snd (tup))), lab_trans);


  local eps_done :: [Integer] = 
    concat (map (step (nfa, _, lab), eps_to));


  return unsafeTrace (eps_done ++ lab_to, printT ("Returning: " ++ implode (" ", map (toString, eps_done ++ lab_to)) ++ "\n", unsafeIO ()));

}




function valid_lab
Boolean ::= want::Label has::Maybe<Label>
{
  return
    case (want, has) of
      (_, nothing ()) -> true
    | (lex_prod (_), just(lex_prod (_))) -> true
    | (ext_prod (_), just(ext_prod (_))) -> true
    | (var_prod (_), just(var_prod (_))) -> true
    | (imp_prod (_), just(imp_prod (_))) -> true
    | (mod_prod (_), just(mod_prod (_))) -> true
    | (rec_prod (_), just(rec_prod (_))) -> true
    | _                                  -> false
    end;
}

function is_eps_trans
Boolean ::= trans::(Integer, Maybe<Label>, Integer)
{
  return
    case trans of
      (_, nothing (), _) -> true
    | _ -> false
    end;
}


{- Utils -}

function state_eq
Boolean ::= s1::Integer s2::Integer nfa::Decorated NFA
{ 
  return unsafeTrace (s1 == s2, printT ("Does " ++ toString(s1) ++ " equal " ++ toString(s2) ++ " ? " ++ toString (s1 == s2) ++ "\n" ++
  "\t Valid transitions: " ++ implode ("\n\t", map ((\pair::(Integer, Maybe<Label>, Integer) -> "(" ++ toString(fst (pair)) ++ ", " ++ toString(snd (snd (pair))) ++ ")"), nfa.transitions)) ++ "\n"
  
  
  , unsafeIO())); 
}
