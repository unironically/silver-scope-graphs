grammar lmlangmap;

terminal ID_t /[a-z][a-zA-Z]*/;
terminal Int_t /(0|-?[1-9][0-9]*)/;

terminal Mod_t 'mod' dominates {ID_t};
terminal Imp_t 'imp' dominates {ID_t};
terminal Def_t 'def' dominates {ID_t};
terminal Fun_t 'fun' dominates {ID_t};

terminal Let_t 'let' precedence = 1, dominates {ID_t};
terminal LetRec_t 'letrec' precedence = 1, dominates {ID_t};
terminal LetPar_t 'letpar' precedence = 1, dominates {ID_t};
terminal In_t 'in' precedence = 4, dominates {ID_t};

terminal Plus_t '+' precedence = 5, association = left;
terminal App_t '' precedence = 6, association = left;
terminal Eq_t '=';

terminal Semi_t ';';
terminal Comma_t ',';
terminal Dot_t '.';

terminal LCurly_t '{';
terminal RCurly_t '}';

ignore terminal Whitespace_t /[\n\r\t ]+/;
