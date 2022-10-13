grammar lmlang_basic_scopetree;

nonterminal Scope with look_for, resolutions;

inherited attribute look_for :: lm:IdRef;
synthesized attribute resolutions :: [Decorated lm:IdDecl];

abstract production empty_scope
top::Scope ::=
{
  resolutions = [];
}

abstract production cons_scope
top::Scope ::= decls::[Decorated lm:IdDecl] rest::Scope
{
  top.resolutions =
    let res::[Decorated lm:IdDecl] = 
      filter((\decl::Decorated lm:IdDecl -> decl.name == top.look_for.name), decls) in 
      if null(res) 
        then (decorate rest with {look_for = top.look_for;}).resolutions
        else res
    end;
}