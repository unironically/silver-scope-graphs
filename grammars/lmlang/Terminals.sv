grammar lmlang;

terminal ID_t /[a-zA-Z_]*/ submits to {True_t, False_t, Import_t, Module_t, Imp_t, 
  Def_t, Fun_t, Let_t, LetRec_t, LetPar_t, In_t};

terminal Int_t /(0|-?[1-9][0-9]*)/;

terminal True_t 'true' dominates {ID_t};
terminal False_t 'false' dominates {ID_t};

terminal Import_t 'import';
terminal Module_t 'module';
terminal Imp_t 'imp';
terminal Def_t 'def';
terminal Fun_t 'fun';

terminal Let_t 'letseq' precedence = 1;
terminal LetRec_t 'letrec' precedence = 1;
terminal LetPar_t 'letpar' precedence = 1;
terminal In_t 'in' precedence = 4;

terminal Plus_t '+' precedence = 5, association = left;
terminal App_t '*' precedence = 6, association = left;
terminal Eq_t '=';

terminal Semi_t ';';
terminal Comma_t ',';
terminal Dot_t '.';

terminal LCurly_t '{';
terminal RCurly_t '}';

ignore terminal Whitespace_t /[\n\r\t ]+/;
