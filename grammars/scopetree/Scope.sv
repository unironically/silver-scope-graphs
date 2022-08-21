grammar scopetree;

--------------------
-- Scope nodes

synthesized attribute id::Integer;
synthesized attribute parent<d r>::Maybe<Scope<d r>>;
synthesized attribute decls<d r>::[Decl<d r>];
synthesized attribute refs<d r>::[Ref<d r>];
synthesized attribute imps<d r>::[Ref<d r>];
synthesized attribute children<d r>::[Scope<d r>];
synthesized attribute assoc_decl<d r>::Maybe<Decl<d r>>;

nonterminal Scope<d r> with id, parent<d r>, decls<d r>, refs<d r>, imps<d r>, children<d r>, assoc_decl<d r>;

abstract production mk_scope
top::Scope<d r> ::= 
  parent::Maybe<Scope<d r>>
  decls::[Decl<d r>] 
  refs::[Ref<d r>] 
  imps::[Ref<d r>] 
  children::[Scope<d r>]
  assoc_decl::Maybe<Decl<d r>>
{
  top.id = genInt();
  top.decls = decls;
  top.refs = refs;
  top.imps = imps;
  top.children = children;
  top.assoc_decl = assoc_decl;
}

--------------------
-- Declaration nodes

synthesized attribute name::String;
synthesized attribute str::String;
synthesized attribute line::Integer;
synthesized attribute column::Integer;
synthesized attribute in_scope<d r>::Scope<d r>;
synthesized attribute assoc_scope<d r>::Maybe<Scope<d r>>;

nonterminal Decl<d r> with name, str, line, column, in_scope<d r>, assoc_scope<d r>;

abstract production mk_decl
  attribute name i occurs on d,
  attribute line i occurs on d,
  attribute column i occurs on d =>
top::Decl<d r> ::= 
  ast_node::Decorated d with i
  in_scope::Scope<d r>
  assoc_scope::Maybe<Scope<d r>>
{
  top.name = ast_node.name;
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.in_scope = in_scope;
  top.assoc_scope = assoc_scope;
}

--------------------
-- Reference/import nodes
synthesized attribute resolutions<d r>::[Decl<d r>];
synthesized attribute res_str::String;
inherited attribute seen_imports<d r>::[Ref<d r>];
inherited attribute seen_scopes<d r>::[Scope<d r>];

nonterminal Ref<d r> with name, str, line, column, in_scope<d r>, seen_scopes<d r>, seen_imports<d r>, resolutions<d r>, res_str;

abstract production mk_ref
  attribute name i occurs on r,
  attribute line i occurs on r,
  attribute column i occurs on r =>
top::Ref<d r> ::= 
  ast_node::Decorated r with i
  in_scope::Scope<d r>
{
  top.name = ast_node.name;
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.in_scope = in_scope;

  -- Resolving the reference:
  top.resolutions = unsafeTrace(resolve_new(top, top.in_scope, top.seen_scopes, top.seen_imports), printlnT("owo", unsafeIO()));

  top.res_str = top.str ++ "{" ++ foldl((\acc::String decl::Decl<d r> -> acc ++ " " ++ decl.str), "", top.resolutions) ++ "}";
}