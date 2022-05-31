grammar lmlangmap;

synthesized attribute id::Integer;
synthesized attribute parent<a>::Maybe<Decorated Scope<a>>;
synthesized attribute declarations<a>::[(String, Decorated Declaration<a>)];
synthesized attribute references<a>::[(String, Decorated Usage<a>)];
synthesized attribute imports<a>::[(String, Decorated Usage<a>)];

nonterminal Scope<a> with id, parent<a>, declarations<a>, references<a>, imports<a>;

abstract production cons_scope
top::Scope<a> ::= par::Maybe<Decorated Scope<a>> decls::[(String, Decorated Declaration<a>)] refs::[(String, Decorated Usage<a>)] imps::[(String, Decorated Usage<a>)]
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



--------------------------------------------------------------------
--- Functions corresponding to the scope graphs resolution algorithm
--------------------------------------------------------------------

function resolve
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] reference::Decorated Usage<a>
{
  return filter ((\s::Decorated Declaration<a> -> s.identifier == reference.identifier), 
    env_v ([reference] ++ seen_imports, [], reference.in_scope));
}

function env_v
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return merge_declarations_with_shadowing (env_l (seen_imports, seen_scopes, current_scope), 
    env_p (seen_imports, seen_scopes, current_scope));
}

function env_l
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return merge_declarations_with_shadowing (env_d (seen_imports, seen_scopes, current_scope), 
    env_i (seen_imports, seen_scopes, current_scope));
}

function env_d
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return 
    if containsBy ((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), current_scope, seen_scopes)
    then []
    else map((\thing::(String, Decorated Declaration<a>) -> snd(thing)), current_scope.declarations);
}

function env_i
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return 
    if (containsBy ((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), current_scope, seen_scopes))
    then []
    else 

      let imp_list::[Decorated Usage<a>] = removeAllBy((\left::Decorated Usage<a> right::Decorated Usage<a> -> left.identifier == right.identifier), seen_imports, map((\thing::(String, Decorated Usage<a>) -> snd(thing)), current_scope.imports)) in

      let res_list::[Decorated Declaration<a>] = foldl((\acc::[Decorated Declaration<a>] thing::Decorated Usage<a> -> acc ++ resolve(seen_imports, thing)), [], imp_list) in

      let scope_list::[Decorated Scope<a>] = foldl((\acc::[Decorated Scope<a>] thing::Decorated Declaration<a> -> acc ++ (case thing.associated_scope of | nothing() -> [] | just(p) -> [p] end)), [], res_list) in

      let last_list::[Decorated Declaration<a>] = 
      foldl((\acc::[Decorated Declaration<a>] thing::Decorated Scope<a> -> env_l(seen_imports, seen_scopes ++ [current_scope], thing)), [], scope_list) in 

      last_list end end end end;
}

function env_p
[Decorated Declaration<a>] ::= seen_imports::[Decorated Usage<a>] seen_scopes::[Decorated Scope<a>] current_scope::Decorated Scope<a>
{
  return 
    case current_scope.parent of
      | nothing() -> []
      | just(p) -> if containsBy ((\left::Decorated Scope<a> right::Decorated Scope<a> -> left.id == right.id), current_scope, seen_scopes)
        then []
        else env_v (seen_imports, current_scope::seen_scopes, p)
    end;
}



@{--
 - Merges two lists of declarations such that the left-hand list shadows the right
 -
 - @param left The left-hand list of declarations, which shadows the right
 - @param right The shadowed right-hand list of declarations
-}
function merge_declarations_with_shadowing
[Decorated Declaration<a>] ::= left::[Decorated Declaration<a>] right::[Decorated Declaration<a>]
{
  return unionBy (\mem_r::Decorated Declaration<a> mem_l::Decorated Declaration<a> -> mem_r.identifier == mem_l.identifier, 
      right , left);
}