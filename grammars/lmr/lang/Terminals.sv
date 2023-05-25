grammar lmr:lang;

terminal Id_t /[a-zA-Z]+/
  submits to {
    True_t, False_t, Module_t, Import_t, Record_t, Def_t, If_t, Then_t, Else_t,
    Fun_t, Let_t, LetRec_t, LetPar_t, In_t, New_t, With_t, Do_t, IntType_t,
    BoolType_t
  };

terminal Int_t /(0|[1-9][0-9]*)/;
terminal True_t 'true';
terminal False_t 'false';

terminal Module_t 'module';
terminal Import_t 'import';
terminal Record_t 'record'; 
terminal Def_t 'def';
terminal Bind_t '=' precedence = 8, association = left;

terminal If_t 'if';
terminal Then_t 'then';
terminal Else_t 'else' precedence = 8, association = left;

terminal Fun_t 'fun';

terminal Let_t 'let';
terminal LetRec_t 'letrec';
terminal LetPar_t 'letpar';
terminal In_t 'in' precedence = 8, association = left;

terminal New_t 'new';
terminal With_t 'with';
terminal Do_t 'do' precedence = 8, association = left;

terminal LBrace_t '{';
terminal RBrace_t '}';
terminal LParen_t '(';
terminal RParen_t ')';

terminal Comma_t ',' precedence = 9, association = left;
terminal Dot_t '.' precedence = 16, association = left;

terminal Colon_t ':' precedence = 15, association = right;
terminal Semi_t ';';

terminal App_t '^' precedence = 15, association = left;
terminal Mul_t '*' precedence = 14, association = left;
terminal Div_t '/' precedence = 14, association = left;
terminal Plus_t '+' precedence = 13, association = left;
terminal Sub_t '-' precedence = 13, association = left;
terminal Eq_t '==' precedence = 12, association = left;
terminal And_t '&' precedence = 11, association = left;
terminal Or_t '|' precedence = 10, association = left;

terminal IntType_t 'int';
terminal BoolType_t 'bool';
terminal Arrow_t '->' precedence = 8, association = right;

ignore terminal Whitespace_t /[\n\r\t ]+/;