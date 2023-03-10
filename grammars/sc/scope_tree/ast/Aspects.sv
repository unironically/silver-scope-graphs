grammar scope_tree:ast;

aspect production root
gs::ScopeGraph ::= main::Scope
{
}

aspect production scope_tr
s::Scope ::= id::Integer dcls_tr::Dcls refs_tr::Refs imps_tr::Refs
{
}


aspect production dcl_tr
d::Dcl ::= n::String ind::Integer
{
}

aspect production dcl_scope_tr
d::Dcl ::= n::String ind::Integer s::Scope
{
}

aspect production dcl_nil
ds::Dcls ::=
{
}

aspect production dcl_cons
ds::Dcls ::= h::Dcl t::Dcls
{}


aspect production ref_tr
r::Ref ::= n::String ind::Integer
{
}

aspect production imp_tr
i::Ref ::= n::String ind::Integer
{
}

aspect production ref_nil
rs::Refs ::=
{
}

aspect production ref_cons
rs::Refs ::= h::Ref t::Refs
{
}
