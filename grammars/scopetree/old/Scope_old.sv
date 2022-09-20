-- grammar scopetree;

nonterminal Scope<d r>;
nonterminal Decl<d r>;
nonterminal Ref<d r>;

synthesized attribute id::Integer occurs on Scope<d r>;
synthesized attribute parent<d r>::Maybe<Scope<d r>> occurs on Scope<d r>;
synthesized attribute decls<d r>::[Decl<d r>] occurs on Scope<d r>;
synthesized attribute refs<d r>::[Ref<d r>] occurs on Scope<d r>;
synthesized attribute imps<d r>::[Ref<d r>] occurs on Scope<d r>;
synthesized attribute children<d r>::[Scope<d r>] occurs on Scope<d r>;
synthesized attribute assoc_decl<d r>::Maybe<Decl<d r>> occurs on Scope<d r>;

synthesized attribute name::String occurs on Ref<d r>, Decl<d r>;
synthesized attribute str::String occurs on Scope<d r>, Ref<d r>, Decl<d r>;
synthesized attribute line::Integer occurs on Ref<d r>, Decl<d r>;
synthesized attribute column::Integer occurs on Ref<d r>, Decl<d r>;
synthesized attribute in_scope<d r>::Scope<d r> occurs on Ref<d r>, Decl<d r>;
synthesized attribute assoc_scope<d r>::Maybe<Scope<d r>> occurs on Decl<d r>;
synthesized attribute resolutions<d r>::[Decl<d r>] occurs on Ref<d r>;

--inherited attribute seen_imports<d r>::[Ref<d r>] occurs on Ref<d r>;
--inherited attribute seen_scopes<d r>::[Scope<d r>] occurs on Ref<d r>;

--------------------
-- Scope nodes

abstract production mk_scope
top::Scope<d r> ::= 
  parent::Maybe<Scope<d r>>
  decls::[Decl<d r>] 
  refs::[Ref<d r>] 
  imps::[Ref<d r>] 
  children::[Scope<d r>]
  assoc_decl::Maybe<Decl<d r>>
  at_prod::String
{

  -- Debugging scope creation:
  top.id = let i::Integer = genInt() in 
    unsafeTrace(i, 
      printT(
        "DEBUG:" ++ " Created scope with id: " ++ toString(i) ++ 
        (case top.parent of nothing() -> "" 
          | just(s) -> ", Par: " ++ toString(s.id) end) ++
        ", from production " ++ at_prod ++ 
        "\n", unsafeIO()
      )
    ) 
  end;

  --top.id = genInt();
  top.parent = parent;
  top.decls = decls;
  top.refs = refs;
  top.imps = imps;
  top.children = children;
  top.assoc_decl = assoc_decl;
  top.str = toString(top.id);
}

--------------------
-- Declaration nodes

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

synthesized attribute lam_resolutions<d r>::([Decl<d r>] ::= [Ref<d r>] [Scope<d r>]) occurs on Ref<d r>;

abstract production mk_ref
  attribute name i occurs on r,
  attribute line i occurs on r,
  attribute column i occurs on r =>
top::Ref<d r> ::= 
  ast_node::Decorated r with i
  in_scope::Scope<d r>
  resolutions::[Decl<d r>]
{
  top.name = ast_node.name;
  top.str = top.name ++ "_" ++ toString(top.line) ++ "_" ++ toString(top.column);
  top.line = ast_node.line;
  top.column = ast_node.column;
  top.in_scope = in_scope;

  top.resolutions = resolutions;
  -- seen_imports as lambda?
  -- top.lam_resolutions = (\seen_imports::[Ref<d r>] seen_scopes::[Scope<d r>] -> lam_resolve_new(top, top.in_scope, seen_imports, seen_scopes));
}
