grammar scope_tree_generic:ast;

{- NFAs -}

nonterminal NFA;
synthesized attribute start :: NFA_State occurs on NFA, DFA;

abstract production nfa_single
top::NFA ::= label::Label
{
  local state1 :: NFA_State = 
    case label of
      mod_prod () -> mk_mod_state (false, [state2])
    | var_prod () -> mk_var_state (false, [state2])
    | rec_prod () -> mk_rec_state (false, [state2])
    | ext_prod () -> mk_ext_state (false, [state2])
    | imp_prod () -> mk_imp_state (false, [state2])
    | lex_prod () -> mk_lex_state (false, [state2])
    end;
  local state2 :: NFA_State = mk_empty_acc_state ();
  
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
  local state1 :: NFA_State = mk_eps_state (false, [n1.start, state2]);
  local state2 :: NFA_State = mk_empty_acc_state ();

  top.start = state1.join ([n1.start, state2]);
}

abstract production nfa_alternate
top::NFA ::= n1::NFA n2::NFA
{
  local state1 :: NFA_State = mk_eps_state (false, [n1.start, n2.start]);
  local state2 :: NFA_State = mk_empty_acc_state ();
  top.start = state1.join ([state2]);
}


nonterminal NFA_State;
synthesized attribute accepting :: Boolean occurs on NFA_State, DFA_State;
synthesized attribute join :: (NFA_State ::= [NFA_State]) occurs on NFA_State;
synthesized attribute eps_closure :: [NFA_State] occurs on NFA_State;
synthesized attribute mod_trans :: [NFA_State] occurs on NFA_State;
synthesized attribute var_trans :: [NFA_State] occurs on NFA_State;
synthesized attribute rec_trans :: [NFA_State] occurs on NFA_State;
synthesized attribute ext_trans :: [NFA_State] occurs on NFA_State;
synthesized attribute imp_trans :: [NFA_State] occurs on NFA_State;
synthesized attribute lex_trans :: [NFA_State] occurs on NFA_State;

abstract production mk_state
top::NFA_State ::= 
  accepting :: Boolean
  eps_trans :: [NFA_State]
  mod_trans :: [NFA_State]
  var_trans :: [NFA_State]
  rec_trans :: [NFA_State]
  ext_trans :: [NFA_State]
  imp_trans :: [NFA_State]
  lex_trans :: [NFA_State]
  {- Leaving the rest of the labels out for now -}
{
  top.accepting = accepting;
  top.mod_trans = mod_trans;
  top.var_trans = var_trans;
  top.rec_trans = rec_trans;
  top.ext_trans = ext_trans;
  top.imp_trans = imp_trans;
  top.lex_trans = lex_trans;

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
      map ((\s :: NFA_State -> s.join (join_to)), var_trans),
      map ((\s :: NFA_State -> s.join (join_to)), rec_trans),
      map ((\s :: NFA_State -> s.join (join_to)), ext_trans),
      map ((\s :: NFA_State -> s.join (join_to)), imp_trans),
      map ((\s :: NFA_State -> s.join (join_to)), lex_trans));
}

abstract production mk_eps_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, trans, [], [], [], [], [], []); }

abstract production mk_mod_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, [], trans, [], [], [], [], []); }

abstract production mk_var_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, [], [], trans, [], [], [], []); }

abstract production mk_rec_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, [], [], [], trans, [], [], []); }

abstract production mk_ext_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, [], [], [], [], trans, [], []); }

abstract production mk_imp_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, [], [], [], [], [], trans, []); }

abstract production mk_lex_state
top::NFA_State ::= 
  accepting :: Boolean
  trans :: [NFA_State]
{ forwards to mk_state (accepting, [], [], [], [], [], [], trans); }

abstract production mk_empty_acc_state
top::NFA_State ::= 
{ forwards to mk_state (true, [], [], [], [], [], [], []); }