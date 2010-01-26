grammar ceylon;

options {
/*    backtrack=true;  */
    memoize=true;
}

compilationUnit 
	:
        '{'
        (statement ';')*
        '}'
	;

statement
	:	
        (declaration
        | expression) ;

declaration
// FIXME: We need a classname like foo.bar.baz, not just a bare identifier
	:	IDENTIFIER IDENTIFIER ('=' expression)?
	;

literal
	: enumerationLiteral
	| integerLiteral
	| FLOATLITERAL
	| CHARLITERAL
	| stringLiteral
	| dateLiteral
    ;	

dateLiteral
    : DATELITERAL | TIMELITERAL;

integerLiteral
	: INTLITERAL
	;

enumerationLiteral
    : 'none'
	|	'{'( SIMPLESTRINGLITERAL)? (',' SIMPLESTRINGLITERAL)* '}'
	;


stringLiteral
    : SIMPLESTRINGLITERAL
        /* | LEFTSTRINGLITERAL expression RIGHTSTRINGLITERAL  */
    ;



expression 
    :   implicationExpression
        (('=' | '+=' | '-=' | '*=' | '/=' | '%=' | '&=' | '|=' | '^=' | '&&=' | '||=') expression)?
        /*    | '{' expression ';' (expression ';')* '}' */
    ;
    
implicationExpression
    :
        disjunctionExpression ('=>' disjunctionExpression)*
    ;

disjunctionExpression
    :
        conjunctionExpression (('||' | '|' '^') conjunctionExpression)*
    ;

conjunctionExpression
    :
        logicalNegationExpression (('&&' | '&') logicalNegationExpression)*
    ;

logicalNegationExpression
	:
        '!' equalityExpression
        | equalityExpression
	;
    
equalityExpression
	:	comparisonExpression
        (('=='|'!='|'===') comparisonExpression)*
	;
    
comparisonExpression
	:
        defaultExpression
        (('<=>'|'<'|'>'|'<='|'>='|'in') defaultExpression)*
	;

defaultExpression
	:	
	existenceEmptinessExpression ('default' defaultExpression)?
	;

existenceEmptinessExpression
    :
        dateCompositionExpression
        ('exists' | 'nonempty') ?
    ;

rangeIntervalEntryExpression
    :
        dateCompositionExpression
        (('..'|'->') dateCompositionExpression)?
    ;

dateCompositionExpression
    :
        additiveExpression ('@' additiveExpression)?
    ;

additiveExpression
    :   multiplicativeExpression
        (('+' |  '-') multiplicativeExpression)*
    ;

multiplicativeExpression 
    :
        unaryExpression
        (   
            (   '*'
            |   '/'
            |   '%'
            )
            unaryExpression
        )*
	;

unaryExpression 
    :   '+'  unaryExpression
    |   '-' unaryExpression
    |   '++' unaryExpression
    |   '--' unaryExpression
    |   unaryExpressionNotPlusMinus
    ;

unaryExpressionNotPlusMinus 
    :   '~' unaryExpression
    |   primary
    ;

primary
	:   IDENTIFIER
        selector*
    | literal
    | parExpression
    ;


orderedParameterValues
	:  '(' expression (COMMA expression)* ')'
	;


selector  
    :   ('.' | '^.'|'?.') (IDENTIFIER | 'this' | 'super' )
    |
        arguments
     |   '[' ( expression ('...'
                           | (',' expression)*
                           | '..' expression)
            | '...' expression)
        ']'        
    ;

arguments 
    :
        '(' positionalArguments ')'
        | '{' namedArguments '}'
    ;

namedArgument
    :
        IDENTIFIER '=' expression
    ;

varargArguments
    :	
        expression (',' expression)*
	;

namedArguments
	:
        ((namedArgument ';') => namedArgument ';')* varargArguments?
	;

expressionList 
    :   expression
        (',' expression
        )*
    ;

parExpression 
    :   '(' expression ')'
    ;

identifierSuffix 
    :	arguments
    ;

positionalArguments
    :   expressionList?
    ;

INTLITERAL
    : ('0' .. '9')('0' .. '9')*
	| '\'' HexDigit HexDigit HexDigit HexDigit '\''
	| '\'' HexDigit HexDigit '\''
	;

fragment
Digit 
    : '0'..'9'
    ;

fragment
Digit2
    : Digit Digit
    ;

DATELITERAL
    : '\'' Digit Digit? '/' Digit Digit '/' Digit Digit Digit Digit  '\''
	;

TIMELITERAL
    : '\'' Digit Digit? ':' Digit Digit (':' Digit Digit ( ':' Digit Digit Digit)?)? '\''
	;

fragment
HexDigit
    :   ('0'..'9'|'a'..'f'|'A'..'F')
    ;

FLOATLITERAL
    :   ('0' .. '9')+ '.' ('0' .. '9')+ Exponent?  
    |   '.' ( '0' .. '9' )+ Exponent?  
    |   ('0' .. '9')+ Exponent  
    ;

fragment 
Exponent    
    :   ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+ 
    ;


CHARLITERAL
    :   '\'' 
        (    ~( '\'' | '\r' | '\n' | '\\')
        | EscapeSequence
        ) 
        '\''
    ; 

SIMPLESTRINGLITERAL
    :   '"' 
        (    ~( '\r' | '\n' | '"' | '\\')   
        | EscapeSequence
        )*
        '"' 
    ;

/*

// There soesn't seem to be any reasonable way to lex these.

LEFTSTRINGLITERAL
    : '"'
        (    ~( '\r' | '\n' | '"' | '\\')   
        | EscapeSequence
        )*
        '${'
    ;

RIGHTSTRINGLITERAL
    : '}'
        (    ~( '\r' | '\n' | '"' | '\\')   
        | EscapeSequence
        )*
        '"'
    ;

*/

fragment
EscapeSequence 
    :   '\\' (
            'b' 
        |   't' 
        |   'n' 
        |   'f' 
        |   'r' 
        |   '\"' 
        |   '\'' 
        )          
    ;     

WS  
    :   (
            ' '
        |    '\r'
        |    '\t'
        |    '\u000C'
        |    '\n'
        ) 
        {
            skip();
        }          
    ;


LINE_COMMENT
    :   '//' ~('\n'|'\r')*  ('\r\n' | '\r' | '\n') 
        {
            skip();
        }
    |   '//' ~('\n'|'\r')*     // a line comment could appear at the end of the file without CR/LF
        {
            skip();
        }
    ;   

CASE
    :   'case'
    ;

CATCH
    :   'catch'
    ;

CLASS
    :   'class'
    ;

CONST
    :   'const'
    ;

CONTINUE
    :   'continue'
    ;

DEFAULT
    :   'default'
    ;

DO
    :   'do'
    ;

ELSE
    :   'else'
    ;

ENUM
    :   'enum'
    ;             

EXISTS
: 'exists'
	;

FINALLY
    :   'finally'
    ;

FOR
    :   'for'
    ;

IF
    :   'if'
    ;

IMPLEMENTS
    :   'implements'
    ;

IMPORT
    :   'import'
    ;

INTERFACE
    :   'interface'
    ;
    
NONEMPTY
: 'nonempty'
	;

PACKAGE
    :   'package'
    ;

PRIVATE
    :   'private'
    ;

PROTECTED
    :   'protected'
    ;

PUBLIC
    :   'public'
    ;

RETURN
    :   'return'
    ;

STATIC
    :   'static'
    ;

SUPER
    :   'super'
    ;

SWITCH
    :   'switch'
    ;

THIS
    :   'this'
    ;

THROW
    :   'throw'
    ;

TRY
    :   'try'
    ;

/*

Surely we're going to need this...

VOLATILE
    :   'volatile'
    ;

*/

WHILE
    :   'while'
    ;

TRUE
    :   'true'
    ;

FALSE
    :   'false'
    ;

OPENPAREN
    :   '('
    ;

CLOSEPAREN
    :   ')'
    ;

LBRACE
    :   '{'
    ;

RBRACE
    :   '}'
    ;

LBRACKET
    :   '['
    ;

RBRACKET
    :   ']'
    ;

SEMI
    :   ';'
    ;

COMMA
    :   ','
    ;

DOT
    :   '.'
    ;

ELLIPSIS
    :   '...'
    ;

EQ
    :   '='
    ;

BANG
    :   '!'
    ;

TILDE
    :   '~'
    ;

QUES
    :   '?'
    ;

COLON
    :   ':'
    ;

EQEQ
    :   '=='
    ;

AMPAMP
    :   '&&'
    ;

BARBAR
    :   '||'
    ;

PLUSPLUS
    :   '++'
    ;

SUBSUB
    :   '--'
    ;

PLUS
    :   '+'
    ;

SUB
    :   '-'
    ;

STAR
    :   '*'
    ;

SLASH
    :   '/'
    ;

AMP
    :   '&'
    ;

BAR
    :   '|'
    ;

CARET
    :   '^'
    ;

PERCENT
    :   '%'
    ;

AT
    :   '@'
    ;

BANGEQ
    :   '!='
    ;

GT
    :   '>'
    ;

LT
    :   '<'
    ;        

DOTS
    : '..'
    ;
    
NEQUAL	:	'<=>'
	;
	
IN	:	'in'
	;

	
HASH	:	'#'
	;

PLUSEQ	:	'+='
	;

IDENTIFIER
    :   IdentifierStart IdentifierPart*
    ;

fragment
IdentifierStart
    :   'A'..'Z'
    |   '_'
    |   'a'..'z'
    ;                
                       
fragment 
IdentifierPart
    :   IdentifierStart
    |   '0'..'9'
    ;
