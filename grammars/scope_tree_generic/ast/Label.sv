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

{- NFAs -}

nonterminal NFA;
synthesized attribute start :: NFA_State occurs on NFA;
synthesized attribute accepts :: (Boolean ::= [Label]) occurs on NFA;

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
  top.accepts = \ls :: [Label] -> nfa_accepts (top.start, ls);
}

abstract production nfa_concatenate
top::NFA ::= n1::NFA n2::NFA
{
  top.start = n1.start.join ([n2.start]);
  top.accepts = \ls :: [Label] -> nfa_accepts (top.start, ls);
}

abstract production nfa_star
top::NFA ::= n1::NFA
{
  local state1 :: NFA_State = mk_state (false, [n1.start, state2], [], []);
  local state2 :: NFA_State = mk_state (true, [], [], []);

  top.start = state1.join ([n1.start, state2]);
  top.accepts = \ls :: [Label] -> nfa_accepts (top.start, ls);
}

abstract production nfa_alternate
top::NFA ::= n1::NFA n2::NFA
{
  local state1 :: NFA_State = mk_state (false, [n1.start, n2.start], [], []);
  local state2 :: NFA_State = mk_state (true, [], [], []);
  top.start = state1.join ([state2]);
  top.accepts = \ls :: [Label] -> nfa_accepts (top.start, ls);
}

function nfa_accepts
Boolean ::= current::NFA_State labels::[Label]
{
  return
    case labels of
      [] -> any (map ((\s::NFA_State -> s.accepting), current :: current.eps_closure))
    | l::ls -> let 
                 stepped :: [NFA_State] = current.step (l) 
               in
                 (! null (stepped)) && any (map (\s :: NFA_State -> nfa_accepts (s, ls), stepped))
               end
    end;
}

nonterminal NFA_State;
synthesized attribute accepting :: Boolean occurs on NFA_State;
synthesized attribute step :: ([NFA_State] ::= Label) occurs on NFA_State;
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

  top.step = \l :: Label ->
    case l of
      mod_prod (_) ->
        top.mod_trans ++ concat (map ((\s :: NFA_State -> s.mod_trans), top.eps_closure))
    | var_prod (_) -> 
        top.var_trans ++ concat (map ((\s :: NFA_State -> s.var_trans), top.eps_closure))
    | _ -> [] {- temporary -}
    end;

  top.join = \join_to :: [NFA_State] -> 
    mk_state (
      false, 
      if top.accepting 
        then join_to ++ map ((\s :: NFA_State -> s.join (join_to)), eps_trans) 
        else map ((\s :: NFA_State -> s.join (join_to)), eps_trans), 
      map ((\s :: NFA_State -> s.join (join_to)), mod_trans), 
      map ((\s :: NFA_State -> s.join (join_to)), var_trans));
}