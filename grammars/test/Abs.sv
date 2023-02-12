grammar test;



nonterminal X;
synthesized attribute all_strs::[String] occurs on X;
synthesized attribute printed::String occurs on X;

abstract production root
x::X ::= y1::Y y2::Y
{
  x.all_strs = [y1.str, y2.str];

  y1.strs = x.all_strs;
  y1.pos = 0;

  y2.strs = x.all_strs;
  y2.pos = 1;

  x.printed = foldl ((\acc::String item::String -> acc ++ item), "", x.all_strs);
}

{-

  - testing harness!
  - then seen_imports stuff

-}

nonterminal Y;
inherited attribute pos::Integer occurs on Y;
inherited attribute strs::[String] occurs on Y;
synthesized attribute str::String occurs on Y;

abstract production y_produce
y::Y ::= str::String
{
  y.str = if contains(str, all_but_nth (0, y.pos, y.strs)) then "0" else str;
}



function all_but_nth
[String] ::= incr::Integer pos::Integer lst::[String] 
{
  return
    case lst of 
    | [] -> []
    | h::t -> if incr == pos 
                then      all_but_nth ((incr + 1), pos, t)
                else h :: all_but_nth ((incr + 1), pos, t)
    end;
}