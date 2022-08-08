grammar scopegraph_kw;

--global graphviz_cols::[String] = ["gold", "deeppink", "green", "purple", "darkorange", "blue"];
global graphviz_font_size::String = "12";

----------------
-- Scope graph:

@{-
 - Draw a scope graph in graphviz.
 -
 - @param graph The scope graph to draw.
 - @return The string with which graphviz will draw a graph.
-}
function graphviz_draw_graph
String ::= graph::Decorated Graph<d r>
{
  return "digraph {{ node [shape=circle style=solid fontsize=" ++ graphviz_font_size ++  "] " ++
    graphviz_scope_labels(graph) ++ "}" ++ 
    --graphviz_scope_components(graph) ++
    "}"
    ;
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
 - Draw the labels of scopes who have a parent, based on their parent's label.
 - E.g. Scope 0 has child scopes 0.0, 0.1, 0.2, etc.
 -
 - @param scope The scope to draw a label for, and whose children to label.
 - @return The graphviz string representing the list of scopes with related labels.
-}
function graphviz_all_scopes
String ::= scope::Decorated Scope<d r> new_label::String
{
  return scope.str ++ "[label=\"" ++ new_label ++ foldl((\acc::String decl::d -> " " ++ decl.name), "", scope.decls) ++ "\"" ++ (case scope.name of | nothing() -> "" | just(s) -> " xlabel=\"" ++ s ++ "\"" end) ++ "];" ++ foldl(
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