grammar lambda;

imports scopegraph as sg;


{-

A scope graph has type `Graph<a>`
- it is constructed from
  - a list of scopes (`Decorated Scope<a>`)
  - a list of paths (`Decorated Path<a>`)    - what are these?

- it also consists of (as attributes)
  - a list of declarations (`Decorated Declaration<a>`) - these are computed from the first 2
  - ?? why not a list of references?  That is why one but not the other??

A scope has type `Scope<a>`
 - it is constructed from
   - an optional parent scope
   - list of declarations - why is this not just Decorated Declaration? Why include the string?
       Maybe just have a `name` attribute of type String on Declaration?

   - list of referencs - same question as above

   - list of imports
   - list of child scopes (`Decorated Scope<a>`)

A declarations has type `Declaration<a>`
  - it is constructed from
    - its identifier - this really should be a `a` instead of a string
    - its scope
    - some "associated scope" maybe for imports?
    - line and column - not needed

I've added a `cons_decl_ref` production that fixes some of these issues

 -}


-- Here I treat a scope graph as a list of scopes. Alternatively it could
-- be the global scope, if all nodes are reachable from the global scope.
synthesized attribute scope_graph :: Decorated sg:Graph<IdDcl IdRef> occurs on Root;

monoid attribute all_scopes :: [ Decorated sg:Scope<IdDcl IdRef> ] occurs on Expr;
monoid attribute all_paths :: [ Decorated sg:Path<IdDcl IdRef> ] occurs on Expr, IdRef;

inherited attribute scope :: Decorated sg:Scope<IdDcl IdRef> occurs on Expr, IdDcl, IdRef;

monoid attribute dcls :: [ Decorated sg:Declaration<IdDcl IdRef> ] occurs on Expr;
-- In this language `dcls` is always empty since we need not collect the 
-- declarations in a scope - they are only on productions that define a scope
-- and thus the information is immediately available.

monoid attribute refs :: [ Decorated sg:Usage<IdDcl IdRef> ] occurs on Expr, IdRef;
--ToDo - rename sg:Declaration and sg:Usage

attribute sg:name, sg:line, sg:column occurs on IdDcl, IdRef;

-- Specify flowtype - this seems to be required by the type system
-- This is done for each nonterminal, so object languages can decide
-- what this is for their nonterminals. This is good.
-- Also, defining it on `name` removes the ambiguity so that we do not
-- need the definition for `line` or `column`.
flowtype sg:name {} on IdDcl, IdRef;


monoid attribute errors :: [ Error ] occurs on Root, Expr, IdDcl, IdRef;

-- Root
aspect production root
r::Root ::= e::Expr
{
  propagate errors;
  r.scope_graph = decorate sg:cons_graph (global_scope :: e.all_scopes, e.all_paths) with {};
  -- ToDo: not sure why this needs to be decorated.

  local attribute global_scope :: sg:Scope<IdDcl IdRef> =
    sg:cons_scope (nothing(), [], [], [], []);
    -- There are no declarations, references, etc in the global scope.

  e.scope = global_scope;
}


-- Expr
aspect production let_expr
e::Expr ::= id::IdDcl t::TypeExpr e1::Expr e2::Expr
{
  propagate errors;
  local attribute new_dcl :: sg:Declaration<IdDcl IdRef> = sg:mk_dcl (id, new_scope, nothing());

  local attribute new_scope :: sg:Scope<IdDcl IdRef> = sg:cons_scope ( just (e.scope), 
    map ( \d :: Decorated sg:Declaration<IdDcl IdRef> -> (d.sg:identifier, d), [ new_dcl ] ),
    map ( \r :: Decorated sg:Usage<IdDcl IdRef> -> (r.sg:identifier, r), e2.refs),
    [],
    e1.all_scopes ++ e2.all_scopes );

  e1.scope = e.scope;
  e2.scope = new_scope;

  e.all_scopes := new_scope :: e1.all_scopes ++ e2.all_scopes;
  e.dcls := [];
  e.refs := e1.refs;

  e.all_paths := [];
}

-- Lambda Expression
aspect production lambda_expr
e::Expr ::= id::IdDcl t::TypeExpr body::Expr
{
  propagate errors;

  local attribute new_dcl :: sg:Declaration<IdDcl IdRef> = sg:mk_dcl (id, new_scope, nothing());

  local attribute new_scope :: sg:Scope<IdDcl IdRef> = sg:cons_scope ( just (e.scope), 
    map ( \d :: Decorated sg:Declaration<IdDcl IdRef> -> (d.sg:identifier, d), [ new_dcl ] ),
    map ( \r :: Decorated sg:Usage<IdDcl IdRef> -> (r.sg:identifier, r), body.refs),
    [],
    body.all_scopes );

  body.scope = new_scope;

  e.all_scopes := new_scope :: body.all_scopes;
  e.dcls := [];
  e.refs := [];

  e.all_paths := [];
}

aspect production id_dcl
i::IdDcl ::= nm::String
{ 
  propagate errors;
  i.sg:name = nm;
  i.sg:line = i.location.line;
  i.sg:column = i.location.column;
}

-- Function Application
aspect production app_expr
e::Expr ::= fun::Expr arg::Expr
{ propagate scope, dcls, refs, all_scopes, all_paths;
  propagate errors;
}

-- Arrithmetic Expresssions
aspect production add_expr
e::Expr ::= l::Expr r::Expr
{ propagate scope, dcls, refs, all_scopes, all_paths;
  propagate errors;
}

aspect production sub_expr
e::Expr ::= l::Expr r::Expr
{ propagate scope, dcls, refs, all_scopes, all_paths;
  propagate errors;
}

aspect production mul_expr
e::Expr ::= l::Expr r::Expr
{ propagate scope, dcls, refs, all_scopes, all_paths;
  propagate errors;
}

aspect production div_expr
e::Expr ::= l::Expr r::Expr
{ propagate scope, dcls, refs, all_scopes, all_paths;
  propagate errors;
}

-- Identifier Reference
aspect production ident
e::Expr ::= id::IdRef
{ propagate scope, dcls, refs, all_scopes, all_paths;
  propagate errors;
}

-- Integer Constant
aspect production int_const
e::Expr ::= num::Integer
{ propagate dcls, refs, all_scopes, all_paths;
  propagate errors;
}

-- Identifier
aspect production id_ref
i::IdRef ::= nm::String
{
  propagate errors;

  i.sg:name = nm;
  i.sg:line = i.location.line;
  i.sg:column = i.location.column;

  local attribute new_use :: sg:Usage<IdDcl IdRef> = 
    sg:mk_ref (i.scope, nothing(), i);
  i.refs := [ new_use ] ;

  i.all_paths := case new_use.sg:resolutions of
                 | [] -> []
                 | dcl::_ -> [ decorate sg:cons_path (new_use, dcl) with {} ]
                 end;

  i.errors <- if null (new_use.sg:resolutions)
              then [ id_not_declared (i) ]
              else [];

}

-- Type Expressions
aspect production arrow_te
t::TypeExpr ::= t1::TypeExpr t2::TypeExpr
{
}

aspect production int_te
t::TypeExpr ::=
{
}

