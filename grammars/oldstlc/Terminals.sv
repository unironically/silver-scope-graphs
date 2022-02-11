grammar oldstlc;

terminal ID_t /[a-zA-Z][a-zA-Z0-9]*/;
terminal Int_t  /(0 | [1-9][0-9]*)/;

terminal Lambda_t '\';
terminal Dot_t '.' precedence = 0;
terminal App_t '' precedence = 1, association = left;

terminal LParen_t '(';
terminal RParen_t ')';

ignore terminal Whitespace_t /[\n\r\t ]+/;
