grammar scope_tree:ast;

{- 

This file provides the API for scope trees. It contains only the
declarations that a user needs to know about.

Name resolution is a ubiquitous problem in analysing programs and
other structures in which entities are declared, given a name, and, in
other locations, refereneced by that name.

Visser et al. proposed scope graphs as a common structure for
representing the scoping structure of a program such that common name
resolution algorithms could be used on it. The object language
constructs a scope graph for a program that captures the name
declarations, uses, and scoping structure of the program.  The
algorithm completes the graph by adding edges from name references to
their declaration.

In reference attribute grammars, name resolution is accomplished in a
similar, but ad-hoc, fashion by defining a reference attribute on name
use productions that points to the declaration of that name. In this
approach, however, each object language typically implements its own
environment for use in name resolution.

The obvious question is how these approaches can be brought together.

The approach taken here to implement scope graphs using reference
attribute grammars.

The object language program constructs a "scope tree" that also
captures the name uses, name declarations, and scoping structure of
the program.

This tree is decorated with attribute values, some of which are
reference attributes. This is to construct a Visser-style scope graph
out of tree nodes in the scope-tree with reference attributes
implementing the edges.


We also use reference attributes to link - in both directions -
relevant object language AST nodes with nodes in the scope-tree/graph.

This file is the API for this scope-tree library, specifying the
nonterminals, productions, and attributes that users of this library
will use.


 -}


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
nonterminal Dcl<d r>;

@{--
 - A tree of declaration nodes.
 - @param d The declaration nonterminal of the object language.
 - @param r The reference nonterminal of the object language.
 -}
nonterminal Dcls<d r>;

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
synthesized attribute resolutions<d r> :: [Decorated Dcl<d r>] with ++
  occurs on Ref<d r>;

@{--
 - Function used to query for the decorated version of a scope graph reference node.
 - TODO: maybe instead search by the identifier - currently the str_id attribute.
 -}
synthesized attribute dec_ref<d r> :: (Decorated Ref<d r> ::= Ref<d r>)
  occurs on Graph<d r>;

@{--
 - All reference nodes in the scope graph.
 -}
monoid attribute all_refs<d r> :: [Decorated Ref<d r>] with [], ++;
attribute all_refs<d r> occurs on Graph<d r>;

-- The following fails to compile:
--  monoid attribute all_refs<d r> :: [Decorated Ref<d r>] with [], ++
--    occurs on Graph<d r>;

@{--
 - All declaration nodes in the scope graph.
 -}
monoid attribute all_dcls<d r> :: [Decorated Dcl<d r>] with [], ++;
attribute all_dcls<d r> occurs on Graph<d r>;

@{--
 - A attribute or references and declarations for the expected string name of the entity.
 -}
synthesized attribute name :: String
  occurs on Ref<d r>, Dcl<d r>;

@{--
 - The identifier of a declaration or reference.
 - This uniquely identifies a reference or declaration from all others.
 -}
synthesized attribute str_id :: String
  occurs on Ref<d r>, Dcl<d r>;

@@{--
 - All declarations and refernces need a link, named `obj` that is
   a reference to the object language declaration or link.
 -}

--synthesized attribute obj_dcl<d r> :: Decorated d with i;
--attribute obj_Dcl<d r> occurs on Dcl<d r>;

--attribute obj<r d i> occurs on Rf<d r i>;

--nonterminal Dcl<d r i>;
--nonterminal Rf<d r i>;


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
    head (filter ((\dr::Decorated Ref<d r> -> dr.str_id == r.str_id), root.refs)));
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
  decls::Dcls<d r> 
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
  attribute str_id i occurs on d,
  attribute name i occurs on d =>
dcl::Dcl<d r> ::=
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
  attribute str_id i occurs on d,
  attribute name i occurs on d =>
dcl::Dcl<d r> ::= 
  objlang_inst::Decorated d with i
  module::Scope<d r> 
{}

@{--
 - Constructing a reference node. Parameterized by a object language reference.
 -
 - @param objlang_inst The corresponding object language reference.
 -}
abstract production mk_ref
  attribute str_id i occurs on r,
  attribute name i occurs on r =>
ref::Ref<d r> ::= 
  objlang_inst::Decorated r with i
{}

@{--
 - Constructing a reference node. Parameterized by a object language reference.
 -
 - @param objlang_inst The corresponding object language reference.
 -}
abstract production mk_imp
  attribute str_id i occurs on r,
  attribute name i occurs on r =>
ref::Ref<d r> ::= 
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
  attribute str_id i occurs on r,
  attribute name i occurs on r =>
ref::Ref<d r> ::= 
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
ds::Dcls<d r> ::= 
  d::Dcl<d r> 
  dt::Dcls<d r>
{}

@{--
 - A node representing the end of a declaration tree.
 -}
abstract production decl_nil
ds::Dcls<d r> ::= 
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
