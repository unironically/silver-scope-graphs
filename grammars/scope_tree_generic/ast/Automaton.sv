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
synthesized attribute rec_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
synthesized attribute ext_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
synthesized attribute imp_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
synthesized attribute lex_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
synthesized attribute step_dfa :: (Maybe<DFA_State> ::= Label) occurs on DFA_State;
synthesized attribute ordered_edges :: [[Label]] occurs on DFA_State;

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

  top.rec_trans_dfa = 
    let 
      recs :: [NFA_State] =  
        concat (map (((\s :: NFA_State -> s.rec_trans)), top.nfa_states))
    in
      if null (recs) 
        then nothing () 
        else just (mk_dfa_state(recs))
    end;

  top.ext_trans_dfa = 
    let 
      exts :: [NFA_State] =  
        concat (map (((\s :: NFA_State -> s.ext_trans)), top.nfa_states))
    in
      if null (exts) 
        then nothing () 
        else just (mk_dfa_state(exts))
    end;

  top.imp_trans_dfa = 
    let 
      imps :: [NFA_State] =  
        concat (map (((\s :: NFA_State -> s.imp_trans)), top.nfa_states))
    in
      if null (imps) 
        then nothing () 
        else just (mk_dfa_state(imps))
    end;

  top.lex_trans_dfa = 
    let 
      lexs :: [NFA_State] =  
        concat (map (((\s :: NFA_State -> s.lex_trans)), top.nfa_states))
    in
      if null (lexs) 
        then nothing () 
        else just (mk_dfa_state(lexs))
    end;

  top.ordered_edges = foldr (keep_available_labs (top, _, _), [], label_ord);

  top.step_dfa = \l :: Label ->
    case l of
      mod_prod () -> top.mod_trans_dfa
    | var_prod () -> top.var_trans_dfa
    | rec_prod () -> top.rec_trans_dfa
    | ext_prod () -> top.ext_trans_dfa
    | imp_prod () -> top.imp_trans_dfa
    | lex_prod () -> top.lex_trans_dfa
    end;

  top.accepting = 
    any (map ((\s :: NFA_State -> s.accepting), top.nfa_states));

}

function has_edge
Boolean ::= s::DFA_State l::Label
{
  return case l of
    mod_prod () -> s.mod_trans_dfa.isJust
  | var_prod () -> s.var_trans_dfa.isJust
  | rec_prod () -> s.rec_trans_dfa.isJust
  | ext_prod () -> s.ext_trans_dfa.isJust
  | imp_prod () -> s.imp_trans_dfa.isJust
  | lex_prod () -> s.lex_trans_dfa.isJust
  end;
}

function keep_available_labs
[[Label]] ::= s::DFA_State ls::[Label] acc::[[Label]]
{
  local filtered_labs :: [Label] = filter (has_edge (s, _), ls);
  return if null (filtered_labs) 
           then acc 
           else filtered_labs :: acc;
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