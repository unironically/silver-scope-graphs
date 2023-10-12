grammar simple;

terminal Int_t /(0|[1-9][0-9]*)/;
terminal True_t 'true';
terminal False_t 'false';

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

ignore terminal Whitespace_t /[\n\r\t ]+/;