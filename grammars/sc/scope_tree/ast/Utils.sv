grammar scope_tree:ast;


function scope_id_eq
Boolean ::= s1::Decorated Scope s2::Decorated Scope
{ return s1.index == s2.index;
}

function ref_id_eq
Boolean ::= r1::Decorated Ref r2::Decorated Ref
{ return r1.index == r2.index;
}

function dcl_name_eq
Boolean ::= d1::Decorated Dcl d2::Decorated Dcl
{ return d1.name == d2.name;
}

function ref_name_eq
Boolean ::= r1::Decorated Ref r2::Decorated Ref
{ return r1.name == r2.name;
}


function get_name_index_ref
(String, Integer) ::= r::Decorated Ref
{
  return (r.name, r.index); 
}

function get_name_index_dcl
(String, Integer) ::= d::Decorated Dcl
{
 return (d.name, d.index); 
}


function get_decorated_ref
Decorated Ref ::= r::(String, Integer) s::ScopeGraph
{
  return case r of
    | (name, index) ->
       case filter (
              (\r::Decorated Ref -> r.name == name && r.index == index), 
              s.all_refs) of
         | [] -> error ("reference not found in all_refs")
         | [r] -> r
         | _ -> error ("reference appeared multiple times in all_refs")
         end
    end;
}
