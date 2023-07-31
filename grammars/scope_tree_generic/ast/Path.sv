grammar scope_tree_generic:ast;

{- Scope edges -}

synthesized attribute src::Scope occurs on Path;
synthesized attribute dst::Scope occurs on Path;
synthesized attribute word::[Label] occurs on Path;
synthesized attribute len::Integer occurs on Path;

{- Paths in query resolutions -}

nonterminal Path;

abstract production path_cons
top::Path ::=
  e::Scope
  l::Label
  p::Path
{
  top.dst = p.dst;
  top.src = e;
  top.word = l :: p.word;
  top.len = 1 + p.len;
}

abstract production path_single
top::Path ::=
  e::Scope
{
  top.dst = e;
  top.word = [];
  top.len = 0;
}

{- Compares two paths.
 - Returns 0 if equal, -1 if p2 is preferred, 1 if p1 is preferred.
 - If two paths have equal labels, but one is shorter, then the shorter one
   is preferred. TODO: is this correct?
 -}
function path_comp
Integer ::=
  p1::Path
  p2::Path
{
  return case (p1, p2) of
           (path_single (_), path_single (_))             -> 0
         | (path_single (_), path_cons (_, _, _))         -> 1
         | (path_cons (_, _, _), path_single (_))         -> -1
         | (path_cons (_, l1, t1), path_cons (_, l2, t2)) -> 
             let 
               lab_comp :: Integer = label_comp (l1, l2)
             in
               if lab_comp == 0
                 then path_comp (t1, t2)
                 else lab_comp
             end
         end;
}