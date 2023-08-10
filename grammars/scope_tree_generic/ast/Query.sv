grammar scope_tree_generic:ast;

type WF_Predicate = (Boolean ::= Datum);

nonterminal Query;
synthesized attribute results::[Path] occurs on Query;

abstract production mk_query
top::Query ::=
  r::Regex
  s::Scope
  wf::WF_Predicate
{ top.results = query_step (r.dfa.start_dfa, wf, s); } -- put filter_best wrapper back

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
           just (datum) -> if d.accepting && wf (datum)
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

  return case next_dfa_state of
           just (d) -> let 
                         cont :: [Path] = 
                          concat (map (query_step (d, wf, _), available_scopes))
                       in
                          map (path_cons (s, l, _), cont)
                       end
         | nothing () -> []
         end;

}

{- Get all edges of a certain label from a scope 
 -}
function scope_edges_lab
[Scope] ::= l::Label s::Scope
{
  return case l of
    mod_prod () -> s.mod_edges
  | var_prod () -> s.var_edges
  | rec_prod () -> s.rec_edges
  | ext_prod () -> s.ext_edges
  | imp_prod () -> s.imp_edges
  | lex_prod () -> s.lex_edges
  end;
}

{--- Filtering for best paths ---}

{- Keep all paths which have the equal best preference.
 - Ideally, we will end up with a singleton list, but this depends on how the 
   object language is implemented.
 -}
function filter_best
[Path] ::= ps::[Path]
{
  return case ps of
           [] -> []
         | h::t -> foldl (keep_eq_paths, [h], t)
         end;
}

{- Compare a path with a list of paths. The list of paths contains all paths of
   equal preference which we have seen so far. We want to determine whether `p`
   is better, worse than, or the same as each of the paths in `eqs`. We keep 
   `p`, `eqs`, or both, depending on the result of path comparison.
 -}
function keep_eq_paths
[Path] ::= eqs::[Path] p::Path
{
  return case path_comp(head (eqs), p) of
           0  -> p :: eqs
         | 1  -> eqs
         | -1 -> [p]
         | _  -> [] {- Impossible -}
         end;
}