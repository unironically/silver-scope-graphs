grammar scope_tree_generic:ast;

{- DFA -}

nonterminal DFA;
synthesized attribute accepts :: (Boolean ::= [Label]) occurs on DFA;
synthesized attribute start_dfa :: DFA_State occurs on DFA;

abstract production mk_dfa
top::DFA ::= 
  nfa :: NFA
{
  local nfa_start :: NFA_State = nfa.start;
  top.start_dfa = mk_dfa_state (nfa_start :: (nfa_start.eps_closure));
  top.accepts = \ls :: [Label] -> dfa_accepts (top.start_dfa, ls);
}

nonterminal DFA_State;
synthesized attribute nfa_states :: [NFA_State] occurs on DFA_State;
synthesized attribute mod_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
synthesized attribute var_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
{- Leaving the rest of the labels out for now -}
synthesized attribute step_dfa :: (Maybe<DFA_State> ::= Label) occurs on DFA_State;

abstract production mk_dfa_state
top::DFA_State ::= 
  nfa_states :: [NFA_State]
{
  
  top.nfa_states = 
    nfa_states ++ concat (map ((\s :: NFA_State -> s.eps_closure), nfa_states));

  top.mod_trans_dfa = 
    let
      mods :: [NFA_State] =
       concat (map (((\s :: NFA_State -> s.mod_trans)), top.nfa_states))
    in
      if null (mods)
        then nothing ()
        else just (mk_dfa_state(mods))
    end;

  top.var_trans_dfa = 
    let 
      vars :: [NFA_State] =  
        concat (map (((\s :: NFA_State -> s.var_trans)), top.nfa_states))
    in
      if null (vars) 
        then nothing () 
        else just (mk_dfa_state(vars))
    end;

  top.step_dfa = \l :: Label ->
    case l of
      mod_prod (_) -> top.mod_trans_dfa
    | var_prod (_) -> top.var_trans_dfa
    | _ -> nothing () {- temporary -}
    end;

  top.accepting = 
    any (map ((\s :: NFA_State -> s.accepting), top.nfa_states));

}

function dfa_accepts
Boolean ::= current::DFA_State labels::[Label]
{
  return
    case labels of
      [] -> current.accepting
    | l::ls -> let 
                 stepped :: Maybe<DFA_State> = current.step_dfa (l) 
               in
                 case stepped of
                   nothing () -> false
                 | just (s) -> dfa_accepts (s, ls)
                 end
               end
    end;
}

{- NFAs -}

nonterminal NFA;
synthesized attribute start :: NFA_State occurs on NFA, DFA;

abstract production nfa_single
top::NFA ::= label::Label
{
  local state1 :: NFA_State = 
    case label of
      mod_prod (_) -> mk_state (false, [], [state2], [])
    | var_prod (_) -> mk_state (false, [], [], [state2])
    | _ -> mk_state (false, [], [], []) {- temporary -}
    end;
  local state2 :: NFA_State = mk_state (true, [], [], []);
  
  top.start = state1;
}

abstract production nfa_concatenate
top::NFA ::= n1::NFA n2::NFA
{
  top.start = n1.start.join ([n2.start]);
}

abstract production nfa_star
top::NFA ::= n1::NFA
{
  local state1 :: NFA_State = mk_state (false, [n1.start, state2], [], []);
  local state2 :: NFA_State = mk_state (true, [], [], []);

  top.start = state1.join ([n1.start, state2]);
}

abstract production nfa_alternate
top::NFA ::= n1::NFA n2::NFA
{
  local state1 :: NFA_State = mk_state (false, [n1.start, n2.start], [], []);
  local state2 :: NFA_State = mk_state (true, [], [], []);
  top.start = state1.join ([state2]);
}


nonterminal NFA_State;
synthesized attribute accepting :: Boolean occurs on NFA_State, DFA_State;
synthesized attribute join :: (NFA_State ::= [NFA_State]) occurs on NFA_State;
synthesized attribute eps_closure :: [NFA_State] occurs on NFA_State;
synthesized attribute mod_trans :: [NFA_State] occurs on NFA_State;
synthesized attribute var_trans :: [NFA_State] occurs on NFA_State;

abstract production mk_state
top::NFA_State ::= 
  accepting :: Boolean
  eps_trans :: [NFA_State]
  mod_trans :: [NFA_State]
  var_trans :: [NFA_State]
  {- Leaving the rest of the labels out for now -}
{
  top.accepting = accepting;
  top.mod_trans = mod_trans;
  top.var_trans = var_trans;

  top.eps_closure =
    if null (eps_trans)
      then []
      else eps_trans ++
           concat (map ((\s :: NFA_State -> s.eps_closure), eps_trans));

  top.join = \join_to :: [NFA_State] -> 
    mk_state (
      false, 
      if top.accepting 
        then join_to ++ map ((\s :: NFA_State -> s.join (join_to)), eps_trans) 
        else map ((\s :: NFA_State -> s.join (join_to)), eps_trans), 
      map ((\s :: NFA_State -> s.join (join_to)), mod_trans), 
      map ((\s :: NFA_State -> s.join (join_to)), var_trans));
}