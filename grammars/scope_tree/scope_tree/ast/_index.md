---
title: "[scope_tree:ast]"
weight: 0
geekdocBreadcrumb: false
---

Contents of `[scope_tree:ast]`: {{< toc-tree >}} 

Defined in this grammar:

{{< hint info >}}
**Parameter `r`**\
 The reference nonterminal of the object language.
{{< /hint >}}

{{< hint info >}}
**Parameter `d`**\
 The declaration nonterminal of the object language.
{{< /hint >}}

<hr/>

## `nonterminal Graph<d r>` {#Graph}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 13](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L13).

The top-level graph.
Params: see above.

<hr/>

## `nonterminal Scope<d r>` {#Scope}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 19](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L19).

A scope node.
Params: see above.

<hr/>

## `nonterminal Scopes<d r>` {#Scopes}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 25](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L25).

A tree of scope nodes.
Params: see above.

<hr/>

## `nonterminal Decl<d r>` {#Decl}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 31](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L31).

A declaration node.
Params: see above.

<hr/>

## `nonterminal Decls<d r>` {#Decls}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 37](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L37).

A tree of declaration nodes.
Params: see above.

<hr/>

## `nonterminal Ref<d r>` {#Ref}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 43](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L43).

A reference/import node.
Params: see above.

<hr/>

## `nonterminal Refs<d r>` {#Refs}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 49](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L49).

A tree of reference/import nodes.
Params: see above.

<hr/>

## `synthesized attribute name :: String` {#name}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 57](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L57).

The name of a declaration or reference.

<hr/>

## `synthesized attribute resolutions<d r> :: [Decorated Decl<d r>]` {#resolutions}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 63](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L63).

The list of declarations that a reference resolves to.

<hr/>

## `synthesized attribute dec_ref<d r> :: (Decorated Ref<d r> ::= Ref<d r>)` {#dec_ref}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 69](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L69).

Function used to query for the decorated version of a scope graph reference node.

<hr/>

## `abstract production mk_graph` &nbsp; (`g::Graph<d r> ::= root::Scope<d r> `) {#mk_graph}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 79](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L79).

{{< hint info >}}
**Parameter `root`**\
 The global scope of a program.
{{< /hint >}}

The top-level scope graph production.

<hr/>

## `abstract production mk_scope` &nbsp; (`s::Scope<d r> ::= decls::Decls<d r> refs::Refs<d r> children::Scopes<d r> `) {#mk_scope}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 94](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L94).

{{< hint info >}}
**Parameter `decls`**\
 The declarations within the scope.
{{< /hint >}}

{{< hint info >}}
**Parameter `refs`**\
 The references within the scope.
{{< /hint >}}

{{< hint info >}}
**Parameter `children`**\
 Child scopes which do not appear in the declaration or reference trees.
{{< /hint >}}

Constructing a scope with declarations, references and child scopes.

<hr/>

## `abstract production mk_scope_qid` &nbsp; (`s::Scope<d r> ::= ref::Ref<d r> `) {#mk_scope_qid}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 106](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L106).

{{< hint info >}}
**Parameter `ref`**\
 The single reference contained within the scope.
{{< /hint >}}

Constructing a scope with a single reference for use in qualified names,

<hr/>

## `abstract production mk_decl` &nbsp; (`attribute name i occurs on d => d::Decl<d r> ::= objlang_inst::Decorated d with i `) {#mk_decl}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 116](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L116).

{{< hint info >}}
**Parameter `objlang_inst`**\
 The corresponding object language declaration.
{{< /hint >}}

Constructing a declaration. Parameterized by a object language declaration.

<hr/>

## `abstract production mk_decl_assoc` &nbsp; (`attribute name i occurs on d => d::Decl<d r> ::= objlang_inst::Decorated d with i module::Scope<d r> `) {#mk_decl_assoc}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 129](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L129).

{{< hint info >}}
**Parameter `objlang_inst`**\
 The corresponding object language declaration.
{{< /hint >}}

{{< hint info >}}
**Parameter `module`**\
 The scope of the module defined.
{{< /hint >}}

Constructing a declaration which has an associated scope. For use in defining
named modules.

<hr/>

## `abstract production mk_ref` &nbsp; (`attribute name i occurs on objr => r::Ref<d r> ::= objlang_inst::Decorated objr with i `) {#mk_ref}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 141](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L141).

{{< hint info >}}
**Parameter `objlang_inst`**\
 The corresponding object language reference.
{{< /hint >}}

Constructing a reference node. Parameterized by a object language reference.

<hr/>

## `abstract production mk_imp` &nbsp; (`attribute name i occurs on objr => r::Ref<d r> ::= objlang_inst::Decorated objr with i `) {#mk_imp}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 152](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L152).

{{< hint info >}}
**Parameter `objlang_inst`**\
 The corresponding object language reference.
{{< /hint >}}

Constructing a reference node. Parameterized by a object language reference.

<hr/>

## `abstract production mk_ref_qid` &nbsp; (`attribute name i occurs on r => r::Ref<d r> ::= objlang_inst::Decorated r with i qid_scope::Scope<d r> `) {#mk_ref_qid}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 166](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L166).

{{< hint info >}}
**Parameter `objlang_inst`**\
 The corresponding object language reference.
{{< /hint >}}

{{< hint info >}}
**Parameter `qid_scope`**\
 The next scope in a qualified identifier.
{{< /hint >}}

Constructing an import node. Parameterized by a object language reference.
Distinguished from mk_ref at scope_tree:ast/Scope.sv#141 by its use as an import in the enclosing
scope of the qualified identifier this reference appears at the end of.

<hr/>

## `abstract production scope_cons` &nbsp; (`ss::Scopes<d r> ::= s::Scope<d r> st::Scopes<d r> `) {#scope_cons}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 181](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L181).

{{< hint info >}}
**Parameter `s`**\
 A scope node.
{{< /hint >}}

{{< hint info >}}
**Parameter `st`**\
 The remaining tree of scopes.
{{< /hint >}}

Constructing a tree of scopes.

<hr/>

## `abstract production scope_nil` &nbsp; (`ss::Scopes<d r> ::= `) {#scope_nil}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 190](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L190).

A node representing the end of a scope tree.

<hr/>

## `abstract production decl_cons` &nbsp; (`ds::Decls<d r> ::= d::Decl<d r> dt::Decls<d r> `) {#decl_cons}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 200](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L200).

{{< hint info >}}
**Parameter `d`**\
 A declaration node.
{{< /hint >}}

{{< hint info >}}
**Parameter `dt`**\
 The remaining tree of declarations.
{{< /hint >}}

Constructing a tree of declarations.

<hr/>

## `abstract production decl_nil` &nbsp; (`ds::Decls<d r> ::= `) {#decl_nil}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 209](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L209).

A node representing the end of a declaration tree.

<hr/>

## `abstract production ref_cons` &nbsp; (`rs::Refs<d r> ::= r::Ref<d r> rt::Refs<d r> `) {#ref_cons}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 219](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L219).

{{< hint info >}}
**Parameter `r`**\
 A reference node.
{{< /hint >}}

{{< hint info >}}
**Parameter `rt`**\
 The remaining tree of reference.
{{< /hint >}}

Constructing a tree of references.

<hr/>

## `abstract production ref_nil` &nbsp; (`rs::Refs<d r> ::= `) {#ref_nil}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Scope.sv line 228](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Scope.sv#L228).

A node representing the end of a reference tree.



{{< expand "Undocumented Items" "..." >}}

## `global graphviz_font_size` {#graphviz_font_size}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Draw.sv line 3](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Draw.sv#L3).

 (Undocumented.)

<hr/>

## `global graphviz_fill_colors` {#graphviz_fill_colors}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Draw.sv line 4](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Draw.sv#L4).

 (Undocumented.)

<hr/>

## `inherited attribute scope_color :: Integer` {#scope_color}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Draw.sv line 9](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Draw.sv#L9).

 (Undocumented.)

<hr/>

## `synthesized attribute string :: String` {#string}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Draw.sv line 12](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Draw.sv#L12).

 (Undocumented.)

<hr/>

## `function node_color` &nbsp; (`String ::= i::Integer `) {#node_color}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Draw.sv line 152](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Draw.sv#L152).

 (Undocumented.)

<hr/>

## `inherited attribute parent<d r> :: Maybe<Decorated Scope<d r>>` {#parent}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 5](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L5).

 (Undocumented.)

<hr/>

## `inherited attribute scope<d r> :: Decorated Scope<d r>` {#scope}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 7](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L7).

 (Undocumented.)

<hr/>

## `synthesized attribute assoc_scope<d r> :: Maybe<Decorated Scope<d r>>` {#assoc_scope}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 9](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L9).

 (Undocumented.)

<hr/>

## `synthesized attribute imps<d r> :: [Decorated Ref<d r>]` {#imps}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 12](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L12).

 (Undocumented.)

<hr/>

## `synthesized attribute iqid_imps<d r> :: [Decorated Ref<d r>]` {#iqid_imps}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 14](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L14).

 (Undocumented.)

<hr/>

## `inherited attribute qid_imp<d r> :: Maybe<Decorated Ref<d r>>` {#qid_imp}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 16](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L16).

 (Undocumented.)

<hr/>

## `synthesized attribute decls<d r> :: [Decorated Decl<d r>]` {#decls}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 19](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L19).

 (Undocumented.)

<hr/>

## `synthesized attribute refs<d r> :: [Decorated Ref<d r>]` {#refs}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 21](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L21).

 (Undocumented.)

<hr/>

## `function combine_decls` &nbsp; (`Decls<d r> ::= ds1::Decls<d r> ds2::Decls<d r> `) {#combine_decls}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 180](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L180).

 (Undocumented.)

<hr/>

## `function combine_refs` &nbsp; (`Refs<d r> ::= rs1::Refs<d r> rs2::Refs<d r> `) {#combine_refs}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Construction.sv line 192](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Construction.sv#L192).

 (Undocumented.)

<hr/>

## `inherited attribute scope_id :: Integer` {#scope_id}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Naming.sv line 5](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Naming.sv#L5).

 (Undocumented.)

<hr/>

## `synthesized attribute last_id :: Integer` {#last_id}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Naming.sv line 7](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Naming.sv#L7).

 (Undocumented.)

<hr/>

## `synthesized attribute id :: String` {#id}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Naming.sv line 10](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Naming.sv#L10).

 (Undocumented.)

<hr/>

## `synthesized attribute str :: String` {#str}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Naming.sv line 13](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Naming.sv#L13).

 (Undocumented.)

<hr/>

## `synthesized attribute substr :: String` {#substr}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Naming.sv line 15](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Naming.sv#L15).

 (Undocumented.)

<hr/>

## `function scope_id` &nbsp; (`String ::= par::Maybe<Decorated Scope<d r>> id::Integer `) {#scope_id}
Contained in grammar `[scope_tree:ast]`. Defined at [scope_tree/ast/Naming.sv line 157](https://github.com/melt-umn/silver/blob/develop/grammars/scope_tree/ast/Naming.sv#L157).

 (Undocumented.)

{{< /expand >}}
