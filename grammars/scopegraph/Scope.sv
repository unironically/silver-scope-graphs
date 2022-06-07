grammar scopegraph;


----------------
-- Scope Graph

synthesized attribute scope_list<a>::[Decorated Scope<a>];

nonterminal Graph<a> with scope_list<a>;

abstract production cons_graph
top::Graph<a> ::= scope_list::[Decorated Scope<a>]
{
  top.scope_list = scope_list;
}


----------------
-- Scopes

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
-- Declarations

synthesized attribute identifier::String; -- Name of the declaration
synthesized attribute in_scope<a>::Decorated Scope<a>; -- Scope in which the declaration resides
synthesized attribute associated_scope<a>::Maybe<Decorated Scope<a>>; -- Scope that this declaration points to (for imports)
synthesized attribute line::Integer;
synthesized attribute column::Integer;

nonterminal Declaration<a> with identifier, in_scope<a>, associated_scope<a>, line, column;

abstract production cons_decl
top::Declaration<a> ::= id::String in_scope_arg::Decorated Scope<a> 
  assoc_scope_arg::Maybe<Decorated Scope<a>> line::Integer column::Integer
{
  -- two productions instead? one with/without assoc scope
  -- line/col number to know which declaration we're seeing in testing
  top.identifier = id;
  top.in_scope = in_scope_arg;
  top.associated_scope = assoc_scope_arg;
  top.line = line;
  top.column = column;
}


----------------
-- Imports/References

inherited attribute linked_node<a>::Decorated Declaration<a>; -- The node that this import points to with an invisible line. added to after resolution

nonterminal Usage<a> with identifier, in_scope<a>, linked_node<a>, line, column;

abstract production cons_usage
top::Usage<a> ::= id::String in_scope_arg::Decorated Scope<a> line::Integer column::Integer
{
  -- line/col number to know which declaration we're seeing in testing
  top.identifier = id;
  top.in_scope = in_scope_arg;
  top.line = line;
  top.column = column;
}