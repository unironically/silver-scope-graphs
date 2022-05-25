grammar lmlangmap;

type Reference = String;

synthesized attribute id::Integer;
synthesized attribute parent<a>::Maybe<Scope<a>>;
synthesized attribute declarations<a>::[(String, Decorated Declaration<a>)];
synthesized attribute references<a>::[(String, Decorated Usage<a>)];
synthesized attribute imports<a>::[(String, Decorated Usage<a>)];

nonterminal Scope<a> with id, parent<a>, declarations<a>, references<a>, imports<a>;

abstract production cons_scope
top::Scope<a> ::= par::Maybe<Scope<a>> decls::[(String, Decorated Declaration<a>)] refs::[(String, Decorated Usage<a>)] imps::[(String, Decorated Usage<a>)]
{
  top.id = genInt();
  top.parent = par;
  top.declarations = decls;
  top.references = refs;
  top.imports = imps;
}

----------------
-- Declarations:

synthesized attribute identifier::String; -- Name of the declaration
synthesized attribute in_scope<a>::Decorated Scope<a>; -- Scope in which the declaration resides
synthesized attribute associated_scope<a>::Maybe<Decorated Scope<a>>; -- Scope that this declaration points to (for imports)

nonterminal Declaration<a> with identifier, in_scope<a>, associated_scope<a>;

abstract production cons_decl
top::Declaration<a> ::= id::String in_scope_arg::Decorated Scope<a> assoc_scope_arg::Maybe<Decorated Scope<a>>
{
  top.identifier = id;
  top.in_scope = in_scope_arg;
  top.associated_scope = assoc_scope_arg;
}

-----------
-- Imports/References (called "Usage" for now until something better comes along):

inherited attribute linked_node<a>::Decorated Declaration<a>; -- The node that this import points to with an invisible line. added to after resolution

nonterminal Usage<a> with identifier, in_scope<a>, linked_node<a>;

abstract production cons_usage
top::Usage<a> ::= id::String in_scope_arg::Decorated Scope<a>
{
  top.identifier = id;
  top.in_scope = in_scope_arg;
}



{-
--------------------------------------------------------------------
--- Functions corresponding to the scope graphs resolution algorithm
--------------------------------------------------------------------

function resolve
[Declaration<a>] ::= seen_scopes::[Scope<a>] current_scope::Scope<a> reference::Reference
{
  return 
    if containsBy ((\left::String right::String -> left == right), reference, current_scope.references)
    then filter ((\s::Declaration<a> -> fst(s) == reference), env_v ([], current_scope))
    else [];
}

function env_p
[Declaration<a>] ::= seen_scopes::[Scope<a>] current_scope::Scope<a>
{
  return 
    case current_scope.parent of
      | nothing() -> []
      | just(p) -> if containsBy ((\left::Scope<a> right::Scope<a> -> left.id == right.id), current_scope, seen_scopes)
        then []
        else env_v (current_scope::seen_scopes, p)
    end;
}

function env_d
[Declaration<a>] ::= seen_scopes::[Scope<a>] current_scope::Scope<a>
{
  return 
    if containsBy ((\left::Scope<a> right::Scope<a> -> left.id == right.id), current_scope, seen_scopes)
    then []
    else current_scope.declarations;
}

function env_v
[Declaration<a>] ::= seen_scopes::[Scope<a>] current_scope::Scope<a>
{
  return merge_declarations_with_shadowing (env_d (seen_scopes, current_scope), env_p (seen_scopes, current_scope));
}

@{--
 - Merges two lists of declarations such that the left-hand list shadows the right
 -
 - @param left The left-hand list of declarations, which shadows the right
 - @param right The shadowed right-hand list of declarations
-}
function merge_declarations_with_shadowing
[Declaration<a>] ::= left::[Declaration<a>] right::[Declaration<a>]
{
  return unionBy (\mem_r::Declaration<a> mem_l::Declaration<a> -> fst(mem_r) == fst(mem_l), 
      right , left);
}
-}