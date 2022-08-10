grammar scopegraph;

global graphviz_cols::[String] = ["gold", "deeppink", "green", "purple", "darkorange", "blue"];
global graphviz_font_size::String = "12";

----------------
-- Scope<d r> graph:

@{-
 - Draw a scope graph in graphviz.
 -
 - @param graph The scope graph to draw.
 - @param draw_paths Indicates whether to draw the resolution paths into the graph.
 - @param draw_children Indicates whether to draw the children of each scope.
 - @return The string with which graphviz will draw a graph.
-}
function graphviz_draw_graph
String ::= graph::Decorated Graph<d r> draw_paths::Boolean draw_children::Boolean
{
  return "digraph {{ node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++  "] " ++
    
    --graphviz_scope_labels(graph) ++
    foldl((\acc::String s::Decorated Scope<d r> -> acc ++ " " ++ s.str), "", graph.scope_list) ++

    "} node [shape=box fontsize=" ++ graphviz_font_size ++  "] edge [arrowhead=normal] " ++
    (if draw_paths then graphviz_paths(graph) ++ "\n" else "") ++
    (if draw_children then graphviz_scope_children(graph.scope_list) else "") ++
    graphviz_all_declrefs(graph) ++
    graphviz_scopes(graph) ++ "}";
}

@{-
 - Collect information to determine the labels of each scope in a graph.
 -
 - @param graph The graph whose scopes to draw.
 - @return The graphviz string representing the list of scope labels.
-}
function graphviz_scope_labels
String ::= graph::Decorated Graph<d r>
{
  return fst(
    -- Label all scopes which do not have parents, starting from 0. Give scopes with parents a label related to their parent. 
    -- The integer in the accumulator is incremented for each orphan scope found.
    foldl(
      (\acc::(String, Integer) scope::Decorated Scope<d r> -> 
        case scope.parent of 
          | nothing() -> (fst(acc) ++ " " ++ graphviz_all_scopes(scope, toString(snd(acc))), snd(acc) + 1) 
          | just(p) -> acc -- Ignore the current scope, handled in graphviz_all_scopes 
        end), 
      ("", 0), 
      graph.scope_list));
}

@{-
 - Collect information to draw a list of scopes in graphviz.
 -
 - @param graph The graph whose scopes to draw.
 - @return The graphviz string representing the list of scopes.
-}
function graphviz_scopes
String ::= graph::Decorated Graph<d r>
{
  return foldl(
    (\acc::String scope::Decorated Scope<d r> -> 
      acc ++ " " ++ scope.str ++ case scope.parent of 
        | nothing() -> "" 
        | just(p) -> " -> " ++ p.str 
      end ++ " " ++ graphviz_scope_components(scope)),
    "",
    graph.scope_list
  );
}

@{-
 - Collect information to draw the declarations, imports, and references for a scope.
 -
 - @param scope The scope whose components to draw.
 - @return The graphviz string representing the list of components.
-}
function graphviz_scope_components
String ::= scope::Decorated Scope<d r>
{
  return 
    -- Declarations
    let scope_decls::String = foldl(
      (\acc::String decl::Decorated Decl<d r> -> 
        acc ++ " " ++ scope.str ++ " -> " ++ decl.str ++ case decl.assoc_scope of
          | nothing() -> "" 
          | just(s) -> "{ edge [arrowhead=onormal]" ++ decl.str ++ " -> " ++ s.str ++ "}" 
        end), 
      "", 
      scope.declarations)
    -- References
    in let scope_refs::String = foldl(
      (\acc::String ref::Decorated Ref<d r> -> 
        acc ++ " " ++ ref.str ++ " -> " ++ scope.str), 
      "", 
      scope.references)
    -- Imports
    in let scope_imports::String = "{edge [arrowhead=onormal] " ++ foldl(
      (\acc::String ref::Decorated Ref<d r> -> 
        acc ++ " " ++ scope.str ++ " -> " ++ ref.str), 
      "", 
      scope.imports) ++ "}"
    in scope_decls ++ scope_refs ++ scope_imports end end end;
}

@{-
 - Collect information to draw a list of scope child edges.
 -
 - @param scopes The list of child edges to draw.
 - @return The graphviz string representing the list of child edges.
-}
function graphviz_scope_children
String ::= scopes::[Decorated Scope<d r>]
{
  return "{edge [arrowhead=vee style=dashed color=gray75 constraint=false] " ++
    foldl(
      (\accone::String parent::Decorated Scope<d r> -> accone ++
        -- Draw edges from parent to all of its child scopes
        foldl(
          (\acc::String child::Decorated Scope<d r> -> 
            acc ++ " " ++ parent.str ++ " -> "  ++ child.str),
          "",
          parent.child_scopes)), 
      "", 
      scopes) ++ "}";
}

@{-
 - Draw resolution paths in graphviz.
 -
 - @param graph The graph to draw resolution edges for.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_paths
String ::= graph::Decorated Graph<d r>
{
  return let all::([Decorated Ref<d r>], [Decorated Ref<d r>]) = 
    -- Partion all references into those with only one resolution, and others which cause errors
    foldl(
      (\acc::([Decorated Ref<d r>], [Decorated Ref<d r>]) scope::Decorated Scope<d r> -> 
        let new_pair::([Decorated Ref<d r>], [Decorated Ref<d r>]) = 
          partition((\usg::Decorated Ref<d r> -> length(usg.resolutions) == 1), 
            scope.references ++ scope.imports)
        in 
          (fst(acc) ++ fst(new_pair), snd(acc) ++ snd(new_pair))
        end),
      ([],[]),
      graph.scope_list)
  in
    -- Draw edges from both lists with different styles
    "{node [color=red fontsize=" ++ graphviz_font_size ++  
    "] edge [arrowhead=vee color=red style=dashed constraint=false]" ++ 
    graphviz_scope_paths(snd(all), false) ++ "}" ++
    "{edge [arrowhead=vee style=dashed constraint=false]" ++ 
    graphviz_scope_paths(fst(all), true) ++ "}"
  end ++ "\n";
}

@{-
 - Draw paths for a list of references in graphviz.
 -
 - @param graph The references to draw resolution edges for.
 - @return The string with which graphviz will draw resolution paths.
-}
function graphviz_scope_paths
String ::= usages::[Decorated Ref<d r>] alternate_cols::Boolean
{
  return foldl(
    (\acc::String ref::Decorated Ref<d r> -> acc ++ " " ++ ref.str ++ " " ++ 
      -- Draw all of the paths for a given reference
      foldl((\acc::String path::Decorated Path<d r> -> acc ++ " " ++ ref.str ++ " -> " ++ 
          path.final.str ++ (if alternate_cols then "[color=" ++ graphviz_color() ++ "]" else "")), 
        "", 
        ref.paths)),
    "", 
    nubBy((\left::Decorated Ref<d r> right::Decorated Ref<d r> -> 
      left.str == right.str), usages)); -- Remove duplicate references
}

@{-
 - Give labels to all references and declarations.
 -
 - @param graph The references to draw references and declarations for.
 - @return The string with which graphviz will draw references and declarations.
-}
function graphviz_all_declrefs
String ::= graph::Decorated Graph<d r>
{
  return "{node [shape=box style=solid fontsize=" ++ graphviz_font_size ++  "]" ++ 
    foldl(
      (\acc::String scope::Decorated Scope<d r> -> acc ++ " " ++
        -- Label all declarations of a scope
        foldl( 
          (\acc::String decl::Decorated Decl<d r> -> 
            acc ++ " " ++ decl.str ++ "[label=<" ++ decl.identifier ++ 
            "<SUB>(" ++ toString(decl.line) ++ "," ++ toString(decl.column) ++ 
            ")</SUB><SUP>D</SUP>>];"),
          "",
          scope.declarations
        ) ++
        -- Label all references of a scope
        foldl( 
          (\acc::String ref::Decorated Ref<d r> -> 
            acc ++ " " ++ ref.str ++ "[label=<" ++ ref.identifier ++ 
            "<SUB>(" ++ toString(ref.line) ++ "," ++ toString(ref.column) ++ 
            ")</SUB><SUP>R</SUP>>];"),
          "",
          scope.references ++ scope.imports
        )
      ), 
      "", 
      graph.scope_list) ++
  "}";
}

@{-
 - Draw the labels of scopes who have a parent, based on their parent's label.
 - E.g. Scope 0 has child scopes 0.0, 0.1, 0.2, etc.
 -
 - @param scope The scope to draw a label for, and whose children to label.
 - @return The graphviz string representing the list of scopes with related labels.
-}
function graphviz_all_scopes
String ::= scope::Decorated Scope<d r> new_label::String
{
  return scope.str ++ "[label=\"" ++ new_label ++ "\"];" ++ foldl(
    (\acc::String child::Decorated Scope<d r> -> 
      acc ++ " " ++ 
      -- Recursively call on children of 'child'
      graphviz_all_scopes(
        child, 
        new_label ++ "." ++ 
        -- Get the index of scope 'child' in the parent's scope list
        toString(positionOfBy(
          (\left::Decorated Scope<d r> right::Decorated Scope<d r> -> left.id == right.id), 
          child, 
          scope.child_scopes)))), 
    "", 
    scope.child_scopes);
}

@{-
 - Selected a color from a list of graphviz colors.
 -
 - @return A graphviz color.
-}
function graphviz_color
String ::=
{
  return last(take((genInt() % length(graphviz_cols)) + 1, graphviz_cols));
}