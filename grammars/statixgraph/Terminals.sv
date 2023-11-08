grammar statixgraph;

terminal Edge_t '->';

terminal LParen_t '(';
terminal RParen_t ')';

terminal EdgeLeft_t '-[';
terminal EdgeRight_t ']->';

terminal Quote_t '"';
terminal Comma_t ',';

terminal Dash_t '-';

terminal Int_t /(0|[1-9][0-9]*)/;

lexer class Keyword;

terminal New_t 'new' lexer classes {Keyword};

terminal Id_t /[a-z][a-zA-Z]*/ submits to {Keyword};

terminal Ty_t /[A-Z]+/ submits to {Keyword};

ignore terminal Whitespace_t /[\n\r\t ]+/;