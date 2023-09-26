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
synthesized attribute fld_trans_dfa :: Maybe<DFA_State> occurs on DFA_State;
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

  top.fld_trans_dfa = 
    let 
      flds :: [NFA_State] =  
        concat (map (((\s :: NFA_State -> s.fld_trans)), top.nfa_states))
    in
      if null (flds) 
        then nothing () 
        else just (mk_dfa_state(flds))
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
    | fld_prod () -> top.fld_trans_dfa
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
  | fld_prod () -> s.fld_trans_dfa.isJust
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