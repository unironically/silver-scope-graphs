grammar scope_tree:ast;

import scope_tree:visser as res;

-- Q: How to get rid of multiple identical @param declarations 
--    while still generating the correct .md documentation?

@{--
 - The top-level graph.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Graph<d r>;

@{--
 - A scope node.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Scope<d r>;

@{--
 - A tree of scope nodes.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Scopes<d r>;

@{--
 - A declaration node.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Decl<d r>;

@{--
 - A tree of declaration nodes.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Decls<d r>;

@{--
 - A reference/import node.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Ref<d r>;

@{--
 - A tree of reference/import nodes.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Refs<d r>;

{-====================-}

@{--
 - The list of declarations that a reference resolves to.
 -}
synthesized attribute resolutions<d r> :: [Decorated Decl<d r>]
  occurs on Ref<d r>;

@{--
 - Function used to query for the decorated version of a scope graph reference node.
 -}
synthesized attribute dec_ref<d r> :: (Decorated Ref<d r> ::= Ref<d r>)
  occurs on Graph<d r>;

{-====================-}

@{--
 - The top-level scope graph production.
 -
 - @param root The global scope of a program.
 -}
abstract production mk_graph
g::Graph<d r> ::= 
  root::Scope<d r>
{
  --g.refs = ..
  --g.dcls = .. (no e!)
  g.dec_ref = (\r::Ref<d r> -> 
    head (filter ((\dr::Decorated Ref<d r> -> dr.name == r.name), root.refs)));
}

@{--
 - Constructing a scope with declarations, references and child scopes.
 -
 - @param decls The declarations within the scope.
 - @param refs The references within the scope.
 - @param children Child scopes which do not appear in the declaration or reference trees.
 -}
abstract production mk_scope
s::Scope<d r> ::= 
  decls::Decls<d r> 
  refs::Refs<d r> 
  children::Scopes<d r>
{}

@{--
 - Constructing a scope with a single reference for use in qualified names,
 -
 - @param ref The single reference contained within the scope.
 -}
abstract production mk_scope_qid
s::Scope<d r> ::= 
  ref::Ref<d r>
{}

@{--
 - Constructing a declaration. Parameterized by a object language declaration.
 -
 - @param objlang_inst The corresponding object language declaration.
 -}
abstract production mk_decl
  attribute name i occurs on d =>
d::Decl<d r> ::=
  objlang_inst::Decorated d with i
{}

@{--
 - Constructing a declaration which has an associated scope. For use in defining
 - named modules.
 -
 - @param objlang_inst The corresponding object language declaration.
 - @param module The scope of the module defined.
 -}
abstract production mk_decl_assoc
  attribute name i occurs on d =>
d::Decl<d r> ::= 
  objlang_inst::Decorated d with i
  module::Scope<d r> 
{}

@{--
 - Constructing a reference node. Parameterized by a object language reference.
 -
 - @param objlang_inst The corresponding object language reference.
 -}
abstract production mk_ref
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{}

@{--
 - Constructing a reference node. Parameterized by a object language reference.
 -
 - @param objlang_inst The corresponding object language reference.
 -}
abstract production mk_imp
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{}

@{--
 - Constructing an import node. Parameterized by a object language reference.
 - Distinguished from @link[mk_ref] by its use as an import in the enclosing
 - scope of the qualified identifier this reference appears at the end of.
 -
 - @param objlang_inst The corresponding object language reference.
 - @param qid_scope The next scope in a qualified identifier.
 -}
abstract production mk_ref_qid
  attribute name i occurs on r =>
r::Ref<d r> ::= 
  objlang_inst::Decorated r with i
  qid_scope::Scope<d r> 
{}

{-====================-}

@{--
 - Constructing a tree of scopes.
 - 
 - @param s A scope node.
 - @param st The remaining tree of scopes.
 -}
abstract production scope_cons
ss::Scopes<d r> ::= 
  s::Scope<d r> 
  st::Scopes<d r>
{}

@{--
 - A node representing the end of a scope tree.
 -}
abstract production scope_nil
ss::Scopes<d r> ::=
{}

@{--
 - Constructing a tree of declarations.
 -
 - @param d A declaration node.
 - @param dt The remaining tree of declarations.
 -}
abstract production decl_cons
ds::Decls<d r> ::= 
  d::Decl<d r> 
  dt::Decls<d r>
{}

@{--
 - A node representing the end of a declaration tree.
 -}
abstract production decl_nil
ds::Decls<d r> ::= 
{}

@{--
 - Constructing a tree of references.
 -
 - @param r A reference node.
 - @param rt The remaining tree of reference.
 -}
abstract production ref_cons
rs::Refs<d r> ::= 
  r::Ref<d r> 
  rt::Refs<d r>
{}

@{--
 - A node representing the end of a reference tree.
 -}
abstract production ref_nil
rs::Refs<d r> ::= 
{}