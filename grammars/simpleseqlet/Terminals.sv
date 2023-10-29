grammar simpleseqlet;

lexer class Keyword;

terminal True_t 'true' lexer classes {Keyword};
terminal False_t 'false' lexer classes {Keyword};

terminal LetSeq_t 'letseq' lexer classes {Keyword};
terminal LetRec_t 'letrec' lexer classes {Keyword};
terminal Comma_t ',';
terminal In_t 'in' lexer classes {Keyword};
terminal End_t 'end' lexer classes {Keyword};

terminal Assign_t '=';

terminal Int_t /(0|[1-9][0-9]*)/;
terminal Id_t /[a-z][a-zA-Z]*/ submits to {Keyword};

terminal Mul_t '*' precedence = 11, association = left;
terminal Div_t '/' precedence = 11, association = left;
terminal Add_t '+' precedence = 10, association = left;
terminal Sub_t '-' precedence = 10, association = left;

terminal Lt_t '<' precedence = 9, association = left;
terminal Gt_t '>' precedence = 9, association = left;
terminal Leq_t '<=' precedence = 9, association = left;
terminal Geq_t '>=' precedence = 9, association = left;
terminal Eq_t '==' precedence = 9, association = left;
terminal Neq_t '!=' precedence = 9, association = left;

terminal Not_t '!' precedence = 8;
terminal And_t '&' precedence = 7, association = left;
terminal Or_t '|' precedence = 6, association = left;

terminal LParen_t '(';
terminal RParen_t ')';

ignore terminal Whitespace_t /[\n\r\t ]+/;