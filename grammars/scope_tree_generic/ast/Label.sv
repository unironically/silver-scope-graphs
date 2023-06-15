grammar scope_tree_generic:ast;

nonterminal Label;

{-

The productions for labels are defined in the object language specification, and
each production for the Label nonterminal pertains to a particular label type,
such as `PAR, `DEC, `REC, etc. 

The ordering of edge labels should also be encoded within the Label nonterminal,
perhaps the tree of Label produtions structurally encodes the '>' relation on
labels within a language specification?

-}


nonterminal Regex;

{-

Something here to encode the regular expressions that are assigned to queries in
the language specifications.

A `next` attribute to signify which edge labels we are allowed to follow for
the next transition?

-}

abstract production concatenate
top::Regex ::= r1::Regex r2::Regex
{}

abstract production star
top::Regex ::= r1::Regex
{}

abstract production alternate
top::Regex ::= r1::Regex r2::Regex
{}

abstract production single
top::Regex ::= label::Label
{}