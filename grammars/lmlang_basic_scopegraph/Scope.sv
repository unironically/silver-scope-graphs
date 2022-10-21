grammar lmlang_basic_scopegraph;

nonterminal Graph<d r> with sg_root_scopes<d r>;
nonterminal Scope<d r> with id, str, sg_parent<d r>, sg_decls<d r>, sg_refs<d r>, sg_imps<d r>;
nonterminal Decl<d r> with str, name, line, column, sg_in_scope<d r>, sg_assoc_scope<d r>;
nonterminal Ref<d r> with str, name, line, column, sg_in_scope<d r>;

synthesized attribute id::Integer;
synthesized attribute str::String;
synthesized attribute name::String;
synthesized attribute line::Integer;
synthesized attribute column::Integer;

synthesized attribute sg_parent<d r>::Maybe<Scope<d r>>;
synthesized attribute sg_root_scopes<d r>::[Decorated Scope<d r>];
synthesized attribute sg_in_scope<d r>::Scope<d r>;
synthesized attribute sg_assoc_scope<d r>::Maybe<Decorated Scope<d r>>;

synthesized attribute sg_ast_decl<d>::Decorated lm:IdDecl occurs on Decl<d r>;
synthesized attribute sg_ast_ref<r>::lm:IdRef occurs on Ref<d r>;

synthesized attribute sg_decls<d r>::[Decorated Decl<d r>];
synthesized attribute sg_refs<d r>::[Decorated Ref<d r>];
synthesized attribute sg_imps<d r>::[Decorated Ref<d r>];

--------------------
-- Graph

abstract production mk_graph
top::Graph<d r> ::=
  root_scopes::[Decorated Scope<d r>]
{
  top.sg_root_scopes = root_scopes;
}

--------------------
-- Scope nodes

abstract production mk_scope
top::Scope<d r> ::= 
  parent::Maybe<Scope<d r>>
  decls::[Decorated Decl<d r>]
  refs::[Decorated Ref<d r>]
  imps::[Decorated Ref<d r>]
{
  top.id = genInt();
  top.sg_parent = parent;
  top.sg_decls = decls;
  top.sg_refs = refs;
  top.sg_imps = imps;
  top.str = toString(top.id);
}

abstract production mk_scope_orphan
top::Scope<d r> ::= 
  decls::[Decorated Decl<d r>]
  refs::[Decorated Ref<d r>]
  imps::[Decorated Ref<d r>]
{ forwards to mk_scope(nothing(), decls, refs, imps); }

abstract production mk_scope_disconnected
top::Scope<d r> ::=
  decls::[Decorated Decl<d r>]
  refs::[Decorated Ref<d r>]
  imps::[Decorated Ref<d r>]
{ forwards to mk_scope(nothing(), decls, refs, imps); }

--------------------
-- Declaration nodes

abstract production mk_decl
top::Decl<d r> ::= 
  in_scope::Scope<d r>
  ast_node::Decorated lm:IdDecl
{
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.name = ast_node.name;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.sg_in_scope = in_scope;
  top.sg_ast_decl = ast_node;
}

--------------------
-- Reference nodes

abstract production mk_ref
top::Ref<d r> ::=
  in_scope::Scope<d r>
  ast_node::lm:IdRef
{
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.name = ast_node.name;
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.sg_in_scope = in_scope;
  top.sg_ast_ref = ast_node;
}