grammar scopegraph;

terminal ID_t /[a-zA-Z]*'_'[1-9][0-9]*/;
terminal Int_t /(0|[1-9][0-9]*)/;

terminal Import_t 'import';
terminal Module_t 'module';

terminal Decl_t 'decl';
terminal Ref_t 'ref';
terminal Imp_t 'imp';

terminal Def_t 'def';

terminal LBrace_t '{';
terminal RBrace_t '}';

ignore terminal Whitespace_t /[\n\r\t ]+/;
