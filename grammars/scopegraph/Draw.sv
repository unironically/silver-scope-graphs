grammar scopegraph;


----------------
-- Resolution paths:

function graphviz_paths
String ::= paths::[Decorated Path<a>]
{
  return "digraph {" ++ graphviz_paths_helper(paths) ++ "}";
}

function graphviz_paths_helper
String ::= paths::[Decorated Path<a>]
{
  return case paths of 
    | [] -> ""
    | h::t -> h.start.to_string ++ "->" ++ h.final.to_string ++ " " ++ graphviz_paths_helper(t)
  end;
}

----------------
-- Scope graph:

function graphviz_scopes
String ::= graph::Decorated Graph<a>
{
  return "digraph {{ node [shape=circle fontsize=12] " ++ foldl((\acc::String scope::Decorated Scope<a> -> acc ++ " " ++ toString(scope.id)), "", graph.scope_list) ++ "} node [shape=box fontsize=12] edge [arrowhead=normal] " ++ graphviz_scopes_helper(graph.scope_list) ++ "}";
}

function graphviz_scopes_helper
String ::= scopes::[Decorated Scope<a>]
{
  return case scopes of 
    | [] -> ""
    | h::t -> h.to_string ++ (case h.parent of | nothing() -> "" | just(p) -> " -> " ++ p.to_string end) ++ " " ++ graphviz_scope_refs(h, h.references) ++ graphviz_scope_decls(h, h.declarations) ++ graphviz_scope_imports(h, h.imports) ++ graphviz_scopes_helper(t)
  end;
}

function graphviz_scope_refs
String ::= scope::Decorated Scope<a> refs::[(String, Decorated Usage<a>)]
{
  return case refs of 
    | [] -> ""
    | (h1, h2)::t -> h2.to_string ++ " -> " ++ scope.to_string ++ " " ++ graphviz_scope_refs(scope, t)
  end;
}

function graphviz_scope_imports
String ::= scope::Decorated Scope<a> refs::[(String, Decorated Usage<a>)]
{
  return case refs of 
    | [] -> ""
    | (h1, h2)::t -> scope.to_string ++ " -> " ++ h2.to_string ++ " " ++ graphviz_scope_imports(scope, t)
  end;
}

function graphviz_scope_decls
String ::= scope::Decorated Scope<a> decls::[(String, Decorated Declaration<a>)]
{
  return case decls of 
    | [] -> ""
    | (h1, h2)::t -> scope.to_string ++ " -> " ++ h2.to_string ++ " " ++ (case h2.associated_scope of | nothing() -> "" | just(s) -> h2.to_string ++ " -> " ++ s.to_string ++ " " end) ++ graphviz_scope_decls(scope, t)
  end;
}

{-
def a = 0 def b = 1 + a def c = 2 let aa = c bb = a cc = b in aa + bb + cc
-}