grammar scope_tree_generic:ast;

{-

TODO:

 - Resolve queries:
   - What is the next label we can take at the current scope? 

-}

nonterminal Query;

abstract production mk_query
top::Query ::=
  r::Regex
  s::Scope
{
  
  local query_dfa :: DFA = r.dfa;
  

}

function query_step
[DFA_State] ::= s::DFA_State scope::Scope
{
  local available_edges :: [Label] = s.next (0);
  return [];
}