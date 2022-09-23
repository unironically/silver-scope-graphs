grammar minijava;

terminal ID_t /[a-zA-Z_][a-zA-Z0-9_]*/;
terminal Int_t /(0|-?[1-9][0-9]*)/;

terminal Class_t 'class' dominates {ID_t};
terminal Interface_t 'interface' dominates {ID_t};
terminal Extends_t 'extends' dominates {ID_t};
terminal Implements_t 'implements' dominates {ID_t};

terminal IntType_t 'int' dominates {ID_t};

terminal Dot_t '.';
terminal Comma_t ',';
terminal SemiColon_t ';';

terminal LCurly_t '{';
terminal RCurly_t '}';
terminal LParen_t '(';
terminal RParen_t ')';

ignore terminal Whitespace_t /[\n\r\t ]+/;