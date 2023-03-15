grammar sg_cs;

terminal ID_t /[a-zA-Z]_[1-9][0-9]*/;
terminal Int_t /(0|[1-9][0-9]*)/;

terminal Module_t 'module';

terminal Decls_t 'decls';
terminal Refs_t 'refs';
terminal Import_t 'import';

terminal LBrace_t '{';
terminal RBrace_t '}';

terminal Comma_t ',';
terminal Dot_t '.';

ignore terminal Whitespace_t /[\n\r\t ]+/;
