grammar scopegraph;

global color_list::[String] = ["gold", "deeppink", "green", "purple", "darkorange", "blue"];

----------------
-- Scope<d r> graph:

@{-
 - Draw a scope graph in graphviz.
 -
 - @param graph The scope graph to draw.
 - @param draw_paths Indicates whether to draw the resolution paths into the graph.
 - @return The string with which graphviz will draw a graph.
-}
function graphviz_draw_graph
String ::= graph::Decorated Graph<d r> draw_paths::Boolean draw_parents::Boolean
{
  return "digraph {{ node [shape=circle style=solid fontsize=12] " ++
    fst(foldl(
      (\acc::(String, Integer) scope::Decorated Scope<d r> -> 
        case scope.parent of 
          | nothing() -> (fst(acc) ++ " " ++ graphviz_all_scopes(scope, toString(snd(acc))), snd(acc) + 1) 
          | just(p) -> (fst(acc) ++ "", snd(acc)) 
        end), 
      ("", 0), 
      graph.scope_list)) ++
    "} node [shape=box fontsize=12] edge [arrowhead=normal] " ++
    (if draw_paths then graphviz_draw_paths(graph) ++ "\n" else "") ++
    graphviz_all_declrefs(graph) ++ "\n" ++
    graphviz_scopes(graph.scope_list) ++ "\n" ++
    (if draw_parents then graphviz_scope_children(graph.scope_list) else "") ++ "}";
}

@{-
 - Collect information to draw a list of scopes in graphviz.
 -
 - @param scopes The list of scopes to draw.
 - @return The graphviz string representing the list of scopes.
-}
function graphviz_scopes
String ::= scopes::[Decorated Scope<d r>]
{
  return case scopes of 
    | [] -> ""
    | h::t -> 
      h.graphviz_name ++ (case h.parent of | nothing() 
        -> "" | just(p) -> " -> " ++ p.graphviz_name end) ++ " " ++ 
      graphviz_scope_refs(h, h.references) ++ 
      graphviz_scope_decls(h, h.declarations) ++ 
      "{edge [arrowhead=onormal] " ++ graphviz_scope_imports(h, h.imports) ++ "}" ++
      graphviz_scopes(t)
  end;
}

@{-
 - Collect information to draw a list of references in graphviz.
 -
 - @param scopes The list of references to draw.
 - @return The graphviz string representing the list of references.
-}
function graphviz_scope_refs
String ::= scope::Decorated Scope<d r> refs::[Decorated Ref<d r>]
{
  return case refs of 
    | [] -> ""
    | h::t -> "<" ++ h.graphviz_name ++ ">" ++ " -> " ++ scope.graphviz_name ++ " " ++ graphviz_scope_refs(scope, t)
  end;
}

@{-
 - Collect information to draw a list of imports in graphviz.
 -
 - @param scopes The list of imports to draw.
 - @return The graphviz string representing the list of imports.
-}
function graphviz_scope_imports
String ::= scope::Decorated Scope<d r> refs::[Decorated Ref<d r>]
{
  return case refs of
    | [] -> ""
    | h::t -> scope.graphviz_name ++ " -> " ++ h.graphviz_name ++ " " ++ graphviz_scope_imports(scope, t)
  end;
}

@{-
 - Collect information to draw a list of declarations in graphviz.
 -
 - @param scopes The list of declarations to draw.
 - @return The graphviz string representing the list of declarations.
-}
function graphviz_scope_decls
String ::= scope::Decorated Scope<d r> decls::[Decorated Decl<d r>]
{
  return case decls of 
    | [] -> ""
    | h::t -> 
      scope.graphviz_name ++ " -> " ++ h.graphviz_name ++ " " ++ 
      (case h.assoc_scope of 
        | nothing() -> "" 
        | just(s) -> "{ edge [arrowhead=onormal]" ++ h.graphviz_name ++ " -> " ++ s.graphviz_name ++ "} " 
      end) ++ 
      graphviz_scope_decls(scope, t)
  end;
}

@{-
 - Collect information to draw a list of scope children edges.
 -
 - @param scopes The list of child edges to draw.
 - @return The graphviz string representing the list of child edges.
-}
function graphviz_scope_children
String ::= scopes::[Decorated Scope<d r>]
{
  return "{edge [color=gray75 constraint=false] " ++
    foldl((\accone::String h::Decorated Scope<d r> ->
    accone ++ (foldl(
      (\acc::String child::Decorated Scope<d r> -> acc ++ " " ++ h.graphviz_name ++ " -> "  ++ child.graphviz_name),
      "",
      h.child_scopes
    ))), "", scopes) ++ "}";
}

@{-
 - Draw resolution paths in graphviz.
 -
 - @param graph The graph to draw resolution edges for.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_draw_paths
String ::= graph::Decorated Graph<d r>
{
  return let all::([Decorated Ref<d r>], [Decorated Ref<d r>]) = 
    foldl(
      (\acc::([Decorated Ref<d r>], [Decorated Ref<d r>]) cur_scope::Decorated Scope<d r> -> 
        let new_pair::([Decorated Ref<d r>], [Decorated Ref<d r>]) = 
          partition((\usg::Decorated Ref<d r> -> length(usg.resolutions) == 1), 
            cur_scope.references ++ cur_scope.imports)
        in 
          (fst(acc) ++ fst(new_pair), snd(acc) ++ snd(new_pair))
        end),
      ([],[]),
      graph.scope_list)
  in
  "{node [color=red fontsize=12] edge [arrowhead=normal color=red style=dashed constraint=false]" ++
      graphviz_draw_individual_paths(snd(all), true) ++ "}" ++
  "{edge [arrowhead=normal style=dashed constraint=false]" ++ 
    graphviz_draw_individual_paths(fst(all), false) ++ "}"
  end ++ "\n";
}

@{-
 - Draw paths for a list of references in graphviz.
 -
 - @param graph The references to draw resolution edges for.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_draw_individual_paths
String ::= usages::[Decorated Ref<d r>] isErrorPaths::Boolean
{
  return foldl(
    (\acc::String usg::Decorated Ref<d r> -> acc ++ " " ++ usg.graphviz_name ++ " " ++ 
      foldl((\acc::String path::Decorated Path<d r> -> acc ++ " " ++ usg.graphviz_name ++ 
          " -> " ++ path.final.graphviz_name ++ "[color=" ++ last(take((genInt()%length(color_list))+1, color_list)) ++ "]"), 
        "", 
        usg.paths)),
    "", 
    nubBy((\left::Decorated Ref<d r> right::Decorated Ref<d r> -> left.to_string == right.to_string), 
      usages));
}

function graphviz_all_declrefs
String ::= graph::Decorated Graph<d r>
{
  return "{node [shape=box style=solid fontsize=12]" ++ 
    foldl((\acc::String scope::Decorated Scope<d r> -> acc ++ " " ++ 
      foldl(
        (\acc::String decl::Decorated Decl<d r> -> acc ++ " " ++ decl.graphviz_name ++ 
          "[label=<" ++ decl.identifier ++ 
          "<SUB>(" ++ toString(decl.line) ++ "," ++ toString(decl.column) ++ 
          ")</SUB><SUP>D</SUP>>];"),
        "",
        scope.declarations
      ) ++
      foldl(
        (\acc::String ref::Decorated Ref<d r> -> acc ++ " " ++ ref.graphviz_name ++ 
          "[label=<" ++ ref.identifier ++ 
          "<SUB>(" ++ toString(ref.line) ++ "," ++ toString(ref.column) ++ 
          ")</SUB><SUP>R</SUP>>];"),
        "",
        scope.references ++ scope.imports
      )
    ), "", graph.scope_list) ++
  "}";
}

function graphviz_all_scopes
String ::= scope::Decorated Scope<d r> new_label::String
{
  return scope.graphviz_name ++ "[label=\"" ++ new_label ++ "\"];" ++ foldl(
    (\acc::String child::Decorated Scope<d r> -> acc ++ " " ++ graphviz_all_scopes(child, new_label ++ "." ++ toString(positionOfBy((\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), child, scope.child_scopes)))), 
    "", 
    scope.child_scopes);
}