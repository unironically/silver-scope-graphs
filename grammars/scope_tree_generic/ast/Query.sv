grammar scope_tree_generic:ast;

{-

TODO:

 - Resolve queries:
   - What is the next label we can take at the current scope? 

 - Query process:

   - Get available edges from current scope
     - Branch off on all equal edges
     - If none come back with results, get next available edges
     - Otherwise, return "shortest" path with respect to path ordering
  

-}

type WF_Predicate = (Boolean ::= Datum);

nonterminal Query;
synthesized attribute results::[Path] occurs on Query;

abstract production mk_query
top::Query ::=
  r::Regex
  s::Scope
  wf::WF_Predicate
{
  local query_dfa :: DFA = r.dfa;
  top.results = query_step (query_dfa.start_dfa, wf, s);
}

{- Begin the query process. Start with a DFA state, a well-formedness predicate,
   and a scope. Check if the current DFA state is accepting - if so, and the 
   current scope satisfies the data well-formedness predicate, then return the
   singleton path (which must be the best). Otherwise, find other paths via 
   edges from the current scope. 
 -}
function query_step
[Path] ::=
  d::DFA_State
  wf::WF_Predicate
  s::Scope
{
  local ord_labs::[[Label]] = d.ordered_edges;
  local rec_result::[Path] = search_edges_outer (ord_labs, d, wf, s);
  return case s.datum of
           just (datum)   -> if d.accepting && wf (datum)
                           then [path_single (s)]
                           else rec_result
         | nothing () -> rec_result
         end;
}

{- Gives a list of paths to declarations found by following all of the equal
   best labels from a scope.
 -}
function search_edges_outer
[Path] ::=
  ord_labs::[[Label]]
  d::DFA_State
  wf::WF_Predicate
  s::Scope
{
  return case ord_labs of
           []      -> []
         | ls::lss -> let 
                        result :: [Path] = search_edges_inner (ls, d, wf, s)
                      in
                        if null (result) 
                          then search_edges_outer (lss, d, wf, s)
                          else result
                      end
         end;
}

{- For a list of equally-weighted edges, continue the query on all scopes
   we can get to by those edges, return all paths found.
 - TODO: Maybe sorting at this point?
 -}
function search_edges_inner
[Path] ::=
  labs::[Label]
  d::DFA_State
  wf::WF_Predicate
  s::Scope
{
  return concat (map (search_edge (_, d, wf, s), labs));
}

{- Recursively call the query step function with the new DFA state,
   same data well-formedness predicate, and new scopes we can get to on the 
   label we are following from the current scope.
 -}
function search_edge
[Path] ::=
  l::Label
  d::DFA_State
  wf::WF_Predicate
  s::Scope
{
  local available_scopes::[Scope] = scope_edges_lab (l, s);
  local next_dfa_state::Maybe<DFA_State> = d.step_dfa (l);
  local result::[Path] = concat (map (query_step (d, wf, _), available_scopes));
  return case next_dfa_state of
           just (d)   -> map (path_cons (s, l, _), result)
         | nothing () -> []
         end;
}

{- Get all edges of a certain label from a scope -}
function scope_edges_lab
[Scope] ::= l::Label s::Scope
{
  return case l of
    mod_prod () -> s.mod_edges
  | var_prod () -> s.var_edges
  | lex_prod () -> s.lex_edges
  | _ -> [] {- Temporary -}
  end;
}






{- All states we can transition to, ordered from left to right 
function ordered_trans
[[DFA_State]] ::= s::DFA_State
{ return map (trans_eq (s, _), s.ordered_edges); }

Transition on all edges that have equal weight 
function trans_eq
[DFA_State] ::= s::DFA_State es::[Label]
{ return filterMap (s.step_dfa(_), es); }

function query_step
Maybe<Path> ::= 
  state::DFA_State 
  scope::Scope 
{
  return nothing ();
}

function do_trans
Maybe<Path> ::= states::[[DFA_State]]
{
  return case states of
           [] -> nothing ()
           h::t -> 
         end;
}

function query_step_tries
[DFA_State] ::= s::DFA_State
{}

function query_step_try
[DFA_State] ::= s::DFA_State i::Integer
{ 
  local available_edges :: [Label] = s.next (i);
  if null (available_edges) 
    then []
    else filterMap (transition (s, _), available_edges);
}

function transition
Maybe<DFA_State> ::= s::DFA_State l::Label
{ return s.step_dfa (l); }
-}