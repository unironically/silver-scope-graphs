grammar sg_cs;

synthesized attribute ast<a> :: a;

nonterminal Program_c   with ast<Program>;
nonterminal NodeList_c  with ast<NodeList>;
nonterminal Dcls_c     with ast<Dcls>;
nonterminal Refs_c      with ast<Refs>;
nonterminal Dcl_c      with ast<Dcl>;
nonterminal Qid_c       with ast<Qid>;

{- Program -}

concrete production program_c
p::Program_c ::= sl::NodeList_c
{
  p.ast = program (sl.ast);
}

{- Node List -}

concrete production nodelist_decls_c
sl::NodeList_c ::= Dcls_t dl::Dcls_c slt::NodeList_c
{
  sl.ast = nodelist_decls (dl.ast, slt.ast);
}

concrete production decl_module_c
sl::NodeList_c ::= Module_t id::ID_t LBrace_t sub::NodeList_c RBrace_t slt::NodeList_c
{
  sl.ast = decl_module (decl (id.lexeme), sub.ast, slt.ast);
}

concrete production nodelist_refs_c
sl::NodeList_c ::= Refs_t rl::Refs_c slt::NodeList_c
{
  sl.ast = nodelist_refs (rl.ast, slt.ast);
}

concrete production nodelist_import_c
sl::NodeList_c ::= Import_t qid::Qid_c slt::NodeList_c
{
  sl.ast = nodelist_import (qid.ast, slt.ast);
}

concrete production nodelist_subscope_c
sl::NodeList_c ::= LBrace_t sub::NodeList_c RBrace_t slt::NodeList_c
{
  sl.ast = nodelist_subscope (sub.ast, slt.ast);
}

concrete production nodelist_nothing_c
sl::NodeList_c ::= 
{
  sl.ast = nodelist_nothing ();
}

{- Dcls -}

concrete production decls_comma_c
ds::Dcls_c ::= id::ID_t Comma_t dst::Dcls_c
{ 
  ds.ast = decls_comma (decl (id.lexeme), dst.ast);
}

concrete production decls_last_c
ds::Dcls_c ::= id::ID_t
{
  ds.ast = decls_last (decl (id.lexeme));
}

{- Refs -}

concrete production refs_comma_c
rs::Refs_c ::= qid::Qid_c Comma_t rst::Refs_c
{ 
  rs.ast = refs_comma (qid.ast, rst.ast);
}

concrete production refs_last_c
rs::Refs_c ::= qid::Qid_c
{
  rs.ast = refs_last (qid.ast);
}

{- Qid -}

concrete production qid_dot_c
q::Qid_c ::= id::ID_t Dot_t qt::Qid_c
{
  q.ast = qid_dot (ref (id.lexeme), qt.ast);
}

concrete production qid_single_c
q::Qid_c ::= id::ID_t
{
  q.ast = qid_single (ref (id.lexeme));
}

{- Terminals -}

terminal ID_t /[a-zA-Z]_[1-9][0-9]*/;
terminal Int_t /(0|[1-9][0-9]*)/;

terminal Module_t 'module';

terminal Dcls_t 'decls';
terminal Refs_t 'refs';
terminal Import_t 'import';

terminal LBrace_t '{';
terminal RBrace_t '}';

terminal Comma_t ',';
terminal Dot_t '.';

ignore terminal Whitespace_t /[\n\r\t ]+/;
