grammar scope_tree_generic:driver;

imports scope_tree_generic:ast;
imports scope_tree_generic:lmr;

function main
IO<Integer> ::= largs::[String]
{

  -- T0
  local s00 :: Scope  = mk_scope ([], [], [], [], [], [s01], []);
  local s01 :: Scope = mk_scope ([], [s0a, s0b], [], [], [], [], []);
  local s0a :: Scope = mk_scope_datum (datum_type ("a", int_type ()), [], [], [], [], [], [], []);
  local s0b :: Scope = mk_scope_datum (datum_type ("b", int_type ()), [], [], [], [], [], [], []);
  local r00 :: Regex = concatenate (star (single(lex_lab)), single (var_lab)); -- LEX VAR
  local p00 :: (Boolean ::= Datum) =
    (\d :: Datum -> case d of
                      datum_type (str, ty) -> str == "a"
                    | _ -> false
                    end);
                   

  -- T1
  local s10 :: Scope  = mk_scope ([], [], [], [], [], [s11], []);
  local s11 :: Scope = mk_scope ([], [], [], [], [s12], [s13], []);
  local s12 :: Scope = mk_scope ([], [s1a1], [], [], [], [], []);
  local s13 :: Scope = mk_scope ([], [s1a2], [], [], [], [], []);
  local s1a1 :: Scope = mk_scope_datum (datum_type ("a", int_type ()), [], [], [], [], [], [], []); -- want
  local s1a2 :: Scope = mk_scope_datum (datum_type ("a", bool_type ()), [], [], [], [], [], [], []);
  local r10 :: Regex = concatenate (star (single(lex_lab)), concatenate (star (single(var_lab)), single (var_lab))); -- LEX*IMP*VAR VAR
  local p10 :: (Boolean ::= Datum) =
    (\d :: Datum -> case d of
                      datum_type (str, ty) -> str == "a"
                    | _ -> false
                    end);


  -- T2
  local s20 :: Scope = mk_scope ([], [], [], [], [s21], [s25], []); 
  local s21 :: Scope = mk_scope ([], [], [], [], [], [s22], []); 
  local s22 :: Scope = mk_scope ([], [], [], [], [s23], [], []); 
  local s23 :: Scope = mk_scope ([], [], [], [], [], [s24], []);
  local s24 :: Scope = mk_scope ([], [s2a11, s2a12], [], [], [], [], []);
  local s2a11 :: Scope = mk_scope_datum (datum_type ("a", int_type ()), [], [], [], [], [], [], []);
  local s2a12 :: Scope = mk_scope_datum (datum_type ("a", bool_type ()), [], [], [], [], [], [], []);
  local s25 :: Scope = mk_scope ([], [s2a2], [], [], [], [], []);
  local s2a2 :: Scope = mk_scope_datum (datum_type ("a", rec_type (mk_scope([],[],[],[],[],[], []))), [], [], [], [], [], [], []);
  local r20 :: Regex = concatenate (star (alternate (single (imp_lab), single(lex_lab))), single (var_lab)); -- (LEX|IMP)* VAR
  local p20 :: (Boolean ::= Datum) =
    (\d :: Datum -> case d of
                      datum_type (str, ty) -> str == "a"
                    | _ -> false
                    end);

  return do {
    
    print ("Tests:\n");

    let t0res :: [Path] = mk_query (r00, s00, p00).results;
    print (
      "T0 result - " ++
      toString (length (t0res)) ++ 
      " - " ++ 
      case head(t0res).tgt.datum of
        just (datum_type (s, t)) -> t.str
      | _ -> "other datum"
      end ++
      " - expect '1 - int'\n"
    );

    let t1res :: [Path] = mk_query (r10, s10, p10).results;
    print (
      "T1 result - " ++
      toString (length (t1res)) ++ 
      " - " ++ 
      case head(t1res).tgt.datum of
        just (datum_type (s, t)) -> t.str
      | _ -> "other datum"
      end ++
      " - expect '1 - bool'\n"
    );

    let t2res :: [Path] = mk_query (r20, s20, p20).results;
    print (
      "T2 result - " ++
      toString (length (t2res)) ++ 
      " - " ++ 
      case head(t2res).tgt.datum of
        just (datum_type (s, t)) -> t.str
      | _ -> "other datum"
      end ++
      " - expect '2 - int'\n"
    );

    {-
    --let regex :: Regex = star (single (mod_lab));
    --let regex :: Regex = concatenate (single (mod_lab), single (mod_lab));
    --let regex :: Regex = star (concatenate (single (mod_lab), single (var_lab)));
    let regex :: Regex = star (alternate (single (var_lab), single (var_lab)));
    --let nfa :: NFA = regex.nfa;
    let dfa :: DFA = mk_dfa (regex.nfa);

    if (dfa.accepts ([]))
      then print ("DFA Accepts 1!\n")
      else print ("DFA Rejects 1!\n");

    print ("--\n");

    if (dfa.accepts ([mod_lab]))
      then print ("DFA Accepts 2!\n")
      else print ("DFA Rejects 2!\n");

    print ("--\n");

    if (dfa.accepts ([mod_lab, mod_lab]))
      then print ("DFA Accepts 3!\n")
      else print ("DFA Rejects 3!\n");

    print ("--\n");

    if (dfa.accepts ([mod_lab, var_lab]))
      then print ("DFA Accepts 4!\n")
      else print ("DFA Rejects 4!\n");
    
    print ("--\n");

    if (dfa.accepts ([var_lab]))
      then print ("DFA Accepts 5!\n")
      else print ("DFA Rejects 5!\n");

    print ("--\n");

    print ("MOD and LEX: " ++ toString (label_comp (mod_lab, lex_lab)) ++ "\n");
    print ("LEX and REC: " ++ toString (label_comp (lex_lab, rec_lab)) ++ "\n");
    print ("IMP and EXT: " ++ toString (label_comp (imp_lab, ext_lab)) ++ "\n");
    -}

    return 0;

  };


}