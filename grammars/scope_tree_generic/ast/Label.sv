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
    | _                        -> false
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

{- NFAs -}


nonterminal NFA;
synthesized attribute start :: NFA_State occurs on NFA;
synthesized attribute accepting :: [NFA_State] occurs on NFA;

abstract production nfa_concatenate
top::NFA ::= n1::NFA n2::NFA
{
  top.start = n1.start.epsilon_combine (n1.accepting, n2.start);
  top.accepting = n2.accepting;
}


abstract production nfa_alternate
top::NFA ::= n1::NFA n2::NFA
{
  local state1 :: NFA_State = mk_nfa_state ([n1.start, n2.start], [], [], [], [], [], []);
  local state2 :: NFA_State = mk_nfa_state ([], [], [], [], [], [], []);

  top.start = state1.epsilon_combine (n1.accepting ++ n2.accepting, state2);
  top.accepting = [state2];
}


abstract production nfa_star
top::NFA ::= n1::NFA
{
  local state1 :: NFA_State = mk_nfa_state ([n1.start, state2], [], [], [], [], [], []);
  local state2 :: NFA_State = mk_nfa_state ([], [], [], [], [], [], []);

  top.start = (state1.epsilon_combine (n1.accepting, n1.start)).epsilon_combine (n1.accepting, state2);
  top.accepting = [state2];
}


abstract production nfa_single
top::NFA ::= label::Label
{
  local state1 :: NFA_State =
    case label of
      mod_prod (_) -> mk_nfa_state ([], [state2], [], [], [], [], [])
    | var_prod (_) -> mk_nfa_state ([], [], [state2], [], [], [], [])
    | rec_prod (_) -> mk_nfa_state ([], [], [], [state2], [], [], [])
    | ext_prod (_) -> mk_nfa_state ([], [], [], [], [state2], [], [])
    | imp_prod (_) -> mk_nfa_state ([], [], [], [], [], [state2], [])
    | lex_prod (_) -> mk_nfa_state ([], [], [], [], [], [], [state2])
    end;
  local state2 :: NFA_State = mk_nfa_state ([], [], [], [], [], [], []);

  top.start = state1;
  top.accepting = [state2];
}


{- NFA states -}

nonterminal NFA_State;
synthesized attribute id::String occurs on NFA_State;
synthesized attribute epsilon_combine :: (NFA_State ::= [NFA_State] NFA_State) occurs on NFA_State;
synthesized attribute next :: ([NFA_State] ::= Label) occurs on NFA_State;

abstract production mk_nfa_state
top::NFA_State ::= 
  eps_trans :: [NFA_State]
  mod_trans :: [NFA_State]
  var_trans :: [NFA_State]
  rec_trans :: [NFA_State]
  ext_trans :: [NFA_State]
  imp_trans :: [NFA_State]
  lex_trans :: [NFA_State]
{

  top.id = toString (genInt ());

  top.epsilon_combine = \ acc::[NFA_State] s::NFA_State ->
    epsilon_combine_f (acc, s, top);

  top.next = \ l::Label ->
    case l of
      mod_prod (_) -> concat (map (grab_all_eps, mod_trans))
    | var_prod (_) -> concat (map (grab_all_eps, var_trans))
    | rec_prod (_) -> concat (map (grab_all_eps, rec_trans))
    | ext_prod (_) -> concat (map (grab_all_eps, ext_trans))
    | imp_prod (_) -> concat (map (grab_all_eps, imp_trans))
    | lex_prod (_) -> concat (map (grab_all_eps, lex_trans))
    end
    ++ concat (map ((\s::NFA_State -> s.next (l)), eps_trans));

}

function grab_all_eps
[NFA_State] ::= s::NFA_State
{
  return
    case s of
      mk_nfa_state (es, _, _, _, _, _, _) ->
        es ++ concat (map (grab_all_eps, es))
    end;
}

function epsilon_combine_f
NFA_State ::= acc::[NFA_State] to_state::NFA_State current_state::NFA_State
{
  return
    case current_state of
      mk_nfa_state (eps, mod, var, rec, ext, imp, lex) ->
        mk_nfa_state (
          let 
            new_eps :: [NFA_State] = epsilon_combine_map (acc, to_state, eps)
          in 
            if containsBy (state_eq, current_state, acc) 
              then to_state :: new_eps 
              else new_eps 
          end,
          epsilon_combine_map (acc, to_state, mod),
          epsilon_combine_map (acc, to_state, var),
          epsilon_combine_map (acc, to_state, rec),
          epsilon_combine_map (acc, to_state, ext),
          epsilon_combine_map (acc, to_state, imp),
          epsilon_combine_map (acc, to_state, lex)
        )
    end;
}

function epsilon_combine_map
[NFA_State] ::= acc::[NFA_State] to_state::NFA_State old::[NFA_State]
{
  return map (epsilon_combine_f (acc, to_state, _), old);
}

function state_eq
Boolean ::= s1::NFA_State s2::NFA_State
{ 
  return s1.id == s2.id; 
}
