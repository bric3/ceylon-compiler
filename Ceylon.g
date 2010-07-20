grammar Ceylon;

options {
    //backtrack=true;
    memoize=true;
    output=AST;
}

tokens {
    LANG_ANNOTATION;
    USER_ANNOTATION;
    ANNOTATION_LIST;
    MEMBER_DECL;
    ABSTRACT_MEMBER_DECL;
    ALIAS_DECL;
    ANNOTATION_NAME;
    ARG_LIST;
    ARG_NAME;
    ANON_METH;
    ATTRIBUTE_SETTER;
    BREAK_STMT;
    CALL_EXPR;
    CATCH_BLOCK;
    CATCH_STMT;
    CHAR_CST;
    CLASS_BODY;
    CLASS_DECL;
    CONDITION;
    DO_BLOCK;
    DO_ITERATOR;
    EXPR;
    FINALLY_BLOCK;
    FORMAL_PARAMETER;
    FORMAL_PARAMETER_LIST;
    IF_FALSE;
    IF_STMT;
    IF_TRUE;
    IMPORT_DECL;
    IMPORT_LIST;
    IMPORT_WILDCARD;
    IMPORT_PATH;
    INIT_EXPR;
    INST_DECL;
    INTERFACE_DECL;
    MEMBER_NAME;
    MEMBER_TYPE;
    NAMED_ARG;
    VARARGS;
    NIL;
    RET_STMT;
    BLOCK;
    THROW_STMT;
    RETRY_STMT;
    TRY_BLOCK;
    TRY_CATCH_STMT;
    TRY_RESOURCE;
    TRY_STMT;
    TYPE_ARG_LIST;
    TYPE_NAME;
    TYPE_PARAMETER_LIST;
    WHILE_BLOCK;
    WHILE_STMT;
    SWITCH_STMT;
    SWITCH_EXPR;
    SWITCH_CASE_LIST;
    CASE_ITEM;
    EXPR_LIST;
    CASE_DEFAULT;
    TYPE_CONSTRAINT_LIST;
    TYPE;
    TYPE_CONSTRAINT;
    TYPE_DECL;
    SATISFIES_LIST;
    ABSTRACTS_LIST;
    SUBSCRIPT_EXPR;
    LOWER_BOUND;
    UPPER_BOUND;
    SELECTOR_LIST;
    TYPE_VARIANCE;
    TYPE_PARAMETER;
    STRING_CONCAT;
    INT_CST;
    FLOAT_CST;
    STRING_CST;
    QUOTE_CST;
    FOR_STMT;
    FOR_ITERATOR;
    FAIL_BLOCK;
    LOOP_BLOCK;
    FOR_CONTAINMENT;
    REFLECTED_LITERAL;
    ENUM_LIST;
    SUPERCLASS;
    PREFIX_EXPR;
    POSTFIX_EXPR;
    EXISTS_EXPR;
    NONEMPTY_EXPR;
    IS_EXPR;
    GET_EXPR;
    SET_EXPR;
    //PRIMARY;
}
@parser::header { package com.redhat.ceylon.compiler.parser; }
@lexer::header { package com.redhat.ceylon.compiler.parser; }

compilationUnit
    : importDeclaration*
      toplevelDeclaration+
      EOF
    -> ^(IMPORT_LIST importDeclaration*)?
       ^(TYPE_DECL toplevelDeclaration)+
    ;

toplevelDeclaration
    : annotations? 
    ( 
        memberDeclaration 
      -> ^(MEMBER_DECL memberDeclaration annotations?)
      | typeDeclaration 
      -> ^(TYPE_DECL typeDeclaration annotations?)
    )
    ;

typeDeclaration
    : classDeclaration
    -> ^(CLASS_DECL classDeclaration)
    | interfaceDeclaration
    -> ^(INTERFACE_DECL interfaceDeclaration)
    | aliasDeclaration
    -> ^(ALIAS_DECL aliasDeclaration)
    ;

importDeclaration
    : 'import' importPath ('.' wildcard | alias)? ';'
    -> ^(IMPORT_DECL importPath wildcard? alias?)
    ;
    
importPath
    : importElement ('.' importElement)*
    -> ^(IMPORT_PATH importElement*)
    ;
    
wildcard
    : '*'
    -> ^(IMPORT_WILDCARD)
    ;
    
alias
    : 'alias' typeName
    -> ^(ALIAS_DECL typeName)
    ;
    
importElement
    : LIDENTIFIER | UIDENTIFIER
    ;

//Note that this accepts more than the language spec
//since it does not enforce that enumerated class 
//instance lists are not allowed inside blocks
block
    : '{' declarationOrStatement* directiveStatement? '}'
    -> ^(BLOCK declarationOrStatement* directiveStatement?)
    ;

/*inlineClassDeclaration
    : 'new' 
      annotations?
      type
      positionalArguments?
      satisfiedTypes?
      inlineClassBody
    ;

inlineClassBody
    : '{' declarationOrStatement* '}'
    ;*/

//We could eliminate the backtracking by requiring
//all member declarations to begin with a keyword
//Note that this accepts more than the language spec
//since it does not enforce that enumerated class
//instances have to be listed together at the top
//of the class body
declarationOrStatement
    : (declarationStart) => declaration | statement
    ;

//TODO: I don't understand why we need to distinguish
//      methods from attributes at this stage. Why not
//      do it later?
declaration
    : annotations? 
    ( 
        memberDeclaration 
      -> ^(MEMBER_DECL memberDeclaration annotations?)
      | typeDeclaration 
      -> ^(TYPE_DECL typeDeclaration annotations?)
      | instance 
      -> ^(INST_DECL instance annotations?)
    )
/*    (((memberHeader memberParameters) => 
            (mem=memberDeclaration 
                -> ^(METHOD_DECL $mem $ann?)))
    | (mem=memberDeclaration 
            -> ^(MEMBER_DECL $mem $ann?))
    | (typ=typeDeclaration 
            -> ^(TYPE_DECL $typ $ann?))
    | (inst=instance
            -> ^(INSTANCE $inst $ann?)))*/
    ;
    
//special rule for syntactic predicates
declarationStart
    :  userAnnotation* ( langAnnotation | memberDeclarationStart | typeDeclarationStart )
    ;

memberDeclarationStart
    : (type|'assign'|'void'|'case') LIDENTIFIER
    ;
    
typeDeclarationStart
    : ('class'|'interface'|'alias') UIDENTIFIER
    ;

//by making these things keywords, we reduce the amount of
//backtracking
langAnnotation
    : PUBLIC
    | MODULE
    | PACKAGE
    | PRIVATE
    | ABSTRACT
    | DEFAULT
    | OVERRIDE
    | OPTIONAL
    | MUTABLE
    | EXTENSION
    | VOLATILE
    ;

statement 
    : expressionStatement
    | controlStructure
    ;

expressionStatement
    : expression ';'!
    ;

directiveStatement
    : directive (';'!)?
    ;

directive
    : returnDirective
    | throwDirective
    | breakDirective
    | continueDirective
    | retryDirective
    ;

returnDirective
    : 'return' expression?
    -> ^(RET_STMT expression?)
    ;

throwDirective
    : 'throw' expression?
    -> ^(THROW_STMT expression?)
    ;

breakDirective
    : 'break' expression?
    -> ^(BREAK_STMT expression?)
    ;

continueDirective
    : 'continue'
    ;

retryDirective
    : 'retry'
    -> ^(RETRY_STMT)
    ;

abstractDeclaration
    : annotations? 
    ( 
        abstractMemberDeclaration 
      -> ^(ABSTRACT_MEMBER_DECL abstractMemberDeclaration annotations?)
      | typeDeclaration 
      -> ^(TYPE_DECL typeDeclaration annotations?)
    )
/*    (((memberHeader memberParameters) => 
        (memberHeader memberParameters ';'
          -> ^(ABSTRACT_METHOD_DECL $ann? memberHeader memberParameters)))
    | (mem=memberDeclaration 
            -> ^(MEMBER_DECL $mem $ann?)))*/
    ;

abstractMemberDeclaration
    : memberHeader memberParameters? ';'!
    ;

memberDeclaration
    : memberHeader memberDefinition
    ;

memberHeader
    : memberType memberName
    -> ^(MEMBER_TYPE memberType) memberName
    | 'assign' memberName
    -> ^(ATTRIBUTE_SETTER memberName)
    ;

memberType
    : type | 'void' | 'local'
    ;

memberParameters
    : typeParameters? formalParameters+ typeConstraints?
    ;

//TODO: should we allow the shortcut style of method
//      definition for a method or getter which returns
//      a parExpression, just like we do for Smalltalk
//      style parameters below?
memberDefinition
    : memberParameters?
      ( block | (specifier | initializer)? ';'! )
    ;
    
interfaceDeclaration
    :
        'interface'!
        typeName
        typeParameters?
        satisfiedTypes?
        typeConstraints?
        interfaceBody
    ;

interfaceBody
    : '{'! abstractDeclaration* '}'!
    ;

aliasDeclaration
    :
        'alias'!
        typeName
        typeParameters?
        satisfiedTypes?
        typeConstraints?
        ';'!
    ;

classDeclaration
    :
        'class'!
        typeName
        typeParameters?
        formalParameters
        extendedType?
        satisfiedTypes?
        typeConstraints?
        classBody
    ;

classBody
    : '{' declarationOrStatement* '}'
    -> ^(BLOCK declarationOrStatement*)
 //    -> ^(CLASS_BODY ^(BLOCK $stmts))
    ;

extendedType
    : 'extends' type positionalArguments
    -> ^(SUPERCLASS type positionalArguments) 
    ;

satisfiedTypes
    : 'satisfies' type (',' type)*
    -> ^(SATISFIES_LIST type+)
    ;

abstractedTypes
    : 'abstracts' type (',' type)*
    -> ^(ABSTRACTS_LIST type+)
    ;

instance
    : 'case'! memberName arguments? (','! | ';'! | '...')
    ;
    
typeConstraint
    : 'where' typeName formalParameters? satisfiedTypes? abstractedTypes?
    -> ^(TYPE_CONSTRAINT typeName formalParameters? satisfiedTypes? abstractedTypes?)
    ;
    
typeConstraints
    : typeConstraint+
    -> ^(TYPE_CONSTRAINT_LIST typeConstraint+)
    ;
    
type
    : parameterizedType //( '[' parameterizedType? ']' )?
    -> parameterizedType //FIXME: unnecessary?
    | 'subtype'
    -> ^(TYPE 'subtype')
    ;

parameterizedType
    : qualifiedTypeName typeArguments?
    -> ^(TYPE qualifiedTypeName typeArguments?)
    ;

annotations
    : annotation+
    -> ^(ANNOTATION_LIST annotation+)
    ;

annotation
    : langAnnotation
    -> ^(LANG_ANNOTATION langAnnotation) 
    | userAnnotation
    ;

//TODO: we could minimize backtracking by limiting the 
//kind of expressions that can appear as arguments to
//the annotation
userAnnotation 
    : annotationName annotationArguments?
    -> ^(USER_ANNOTATION annotationName annotationArguments?)
    ;

annotationArguments
    : arguments | 
    ( 
    (SIMPLESTRINGLITERAL) => SIMPLESTRINGLITERAL -> ^(STRING_CST SIMPLESTRINGLITERAL)
    | literal | reflectedLiteral )+
    ;

reflectedLiteral 
    : '#' ( memberName | (parameterizedType ( '.' memberName )? ) )
    -> ^(REFLECTED_LITERAL parameterizedType? memberName?)
    ;

qualifiedTypeName
    : UIDENTIFIER ('.' UIDENTIFIER)*
    -> ^(TYPE_NAME UIDENTIFIER+) 
    ;

typeName
    : UIDENTIFIER
    -> ^(TYPE_NAME UIDENTIFIER)
    ;

annotationName
    : LIDENTIFIER
    -> ^(ANNOTATION_NAME LIDENTIFIER)
    ;

memberName 
    : LIDENTIFIER
    -> ^(MEMBER_NAME LIDENTIFIER)
    ;

typeArguments
    : '<' type (',' type)* '>'
    -> ^(TYPE_ARG_LIST type+)
    ;

typeParameters
    : '<' typeParameter (',' typeParameter)* '>'
    -> ^(TYPE_PARAMETER_LIST typeParameter+)
    ;

typeParameter
    : variance? typeName
    -> ^(TYPE_PARAMETER ^(TYPE_VARIANCE variance)? typeName)
    ;

variance
    : 'in' -> IN | 'out' -> OUT
    // I think this should be equivalent to simply
    // IN | OUT but that is compiled incorrectly and generates errors elsewhere.
    ;
    
//for locals and attributes
initializer
    : ':=' expression
    -> ^(INIT_EXPR expression)
    ;

//for parameters
specifier
    : '=' expression
    -> ^(INIT_EXPR expression)
    ;

literal
    : nonstringLiteral
    | stringExpression
    ;

nonstringLiteral
    : NATURALLITERAL
    -> ^(INT_CST NATURALLITERAL)
    | FLOATLITERAL
    -> ^(FLOAT_CST FLOATLITERAL)
    | QUOTEDLITERAL
    -> ^(QUOTE_CST QUOTEDLITERAL)
    | CHARLITERAL
    -> ^(CHAR_CST CHARLITERAL)
    ;

stringExpression
    : (SIMPLESTRINGLITERAL (interpolatedExpressionStart|SIMPLESTRINGLITERAL)) 
        => stringTemplate
    -> ^(STRING_CONCAT stringTemplate)
    | SIMPLESTRINGLITERAL
    -> ^(STRING_CST SIMPLESTRINGLITERAL)
    ;

stringTemplate
    : SIMPLESTRINGLITERAL 
    ( (interpolatedExpressionStart|SIMPLESTRINGLITERAL) => 
        ( (interpolatedExpressionStart) => expression )? 
        SIMPLESTRINGLITERAL 
    )+
    ;

//special rule for syntactic predicates
//this includes every token that could be 
//the beginning of an expression, except 
//for SIMPLESTRINGLITERAL and '['
interpolatedExpressionStart
    : '(' 
    | '{'
    | '#' 
    | LIDENTIFIER 
    | UIDENTIFIER 
    | specialValue 
    | nonstringLiteral
    | prefixOperator
    | 'get'
    | 'set'
    ;

expression
    : assignmentExpression
    -> ^(EXPR assignmentExpression)
    ;

//Even though it looks like this is non-associative
//assignment, it is actually right associative because
//assignable can be an assignment
//Note that = is not really an assignment operator, but 
//can be used to init locals
assignmentExpression
    : implicationExpression
      (('='^ | ':='^ | '.='^ | '+='^ | '-='^ | '*='^ | '/='^ | '%='^ | '&='^ | '|='^ | '^='^ | '&&='^ | '||='^ | '?='^) expression )?
    ;

implicationExpression
    : disjunctionExpression 
      ('=>'^ disjunctionExpression)?
    ;

//should '^' have a higher precedence?
disjunctionExpression
    : conjunctionExpression 
      ('||'^ conjunctionExpression)?
    ;

conjunctionExpression
    : logicalNegationExpression 
      ('&&'^ logicalNegationExpression)*
    ;

logicalNegationExpression
    : '!'^ logicalNegationExpression
    | equalityExpression
    ;

equalityExpression
    : comparisonExpression
      (('=='^|'!='^|'==='^) comparisonExpression)?
    ;

comparisonExpression
    : defaultExpression
      (('<=>'^ |'<'^ |'>'^ |'<='^ |'>='^ |'in'^ |'is'^) defaultExpression)?
    | reflectedLiteral //needs to be here since it can contain type args
    ;

//should we reverse the precedence order 
//of '?' and 'exists'/'nonempty'?
defaultExpression
    : existenceEmptinessExpression 
      ('?'^ defaultExpression)?
    ;

/*
existenceEmptinessExpression
    : e=rangeIntervalEntryExpression 
    ('exists' -> ^(EXISTS_EXPR $e) 
     | 'nonempty' -> ^(NONEMPTY_EXPR $e)
     | -> $e)
    ;
*/

existenceEmptinessExpression
    : e=rangeIntervalEntryExpression
       (('exists' -> ^(EXISTS_EXPR $e))
        | ('nonempty' -> ^(NONEMPTY_EXPR $e)) )?
     -> $e
    ;

//I wonder if it would it be cleaner to give 
//'..' a higher precedence than '->'
rangeIntervalEntryExpression
    : additiveExpression
      (('..'^ |'->'^) additiveExpression)?
    ;

additiveExpression
    : multiplicativeExpression
      (('+'^ | '-'^ | '|'^ | '^'^) multiplicativeExpression)*
    ;

multiplicativeExpression 
    : exponentiationExpression
      (('*'^ | '/'^ | '%'^ | '&'^) exponentiationExpression)*
    ;

exponentiationExpression
    : unaryExpression ('**'^ unaryExpression)?
    ;

unaryExpression 
    : prefixOperator unaryExpression
    -> ^(PREFIX_EXPR prefixOperator unaryExpression)
    | primary
    ;

prefixOperator
    : '$' | '-' |'++' | '--' | '~'
    ;

specialValue
    : 'this' 
    | 'super' 
    | 'null'
    | 'none'
    ;

enumeration
    : '{' expressions? '}'
    -> ^(ENUM_LIST expressions?)
    ;

primary
    : getterSetterMethodReference
    | prim
    //-> ^(PRIMARY prim)
    ;	
    
prim
options {backtrack=true;}
/*
    : b=base 
    ((selector+
     -> ^(SELECTOR_LIST $b selector+))
    | -> $b
    )
*/
// This backtracking predicate really shouldn't be necessary, and the ANTLR
// book seems to agree, but the above doesn't work.
//    : base selector+ -> ^(SELECTOR_LIST base selector+)
//    | base
    : //base selector* 
    base selector+
    -> ^(EXPR base selector*)
    | base
    ;

getterSetterMethodReference
    : 'set' prim -> ^(SET_EXPR prim)
    | 'get' prim -> ^(GET_EXPR prim)
    ;

postfixOperator
    : '--' | '++'
    ;	

base 
    : literal
    | parExpression
    | enumeration
    | specialValue
    | nameAndTypeArguments
    //| inlineClassDeclaration
    ;
    
selector 
    : member
    | argumentsWithFunctionalArguments
    -> ^(CALL_EXPR argumentsWithFunctionalArguments)
    | elementSelector
    | postfixOperator 
    -> ^(POSTFIX_EXPR postfixOperator)
    ;

member
    : ('.' | '?.' | '*.') nameAndTypeArguments
    ;

nameAndTypeArguments
    : ( memberName | typeName ) 
      ( ( typeArguments ('('|'{') ) => typeArguments )?
    ;

elementSelector
    : '?'? '[' elementsSpec ']'
    -> ^(SUBSCRIPT_EXPR '?'? elementsSpec)
    ;

elementsSpec
    : additiveExpression ( '...' | '..' additiveExpression )?
    -> ^(LOWER_BOUND additiveExpression) ^(UPPER_BOUND additiveExpression)?	
    ;

argumentsWithFunctionalArguments
    : arguments functionalArgument*
    ;
    
arguments
    : positionalArguments | namedArguments
    ;
    
namedArgument
    : namedSpecifiedArgument | namedFunctionalArgument
    ;

namedFunctionalArgument
    : (formalParameterType|'local') parameterName formalParameters* block
    ;

namedSpecifiedArgument
    : parameterName specifier ';'!
    ;

namedArgumentStart
    : LIDENTIFIER '=' 
    | (formalParameterType|'local') LIDENTIFIER
    ;

parameterName
    : LIDENTIFIER
    -> ^(ARG_NAME LIDENTIFIER)
    ;

namedArguments
    : '{' ((namedArgumentStart) => namedArgument)* expressions? '}'
    -> ^(ARG_LIST ^(NAMED_ARG namedArgument)* ^(VARARGS expressions)?)
    ;

parExpression 
    : '('! expression ')'!
    ;
    
positionalArguments
    : '(' ( positionalArgument (',' positionalArgument)* )? ')'
    -> ^(ARG_LIST positionalArgument*)
    ;

positionalArgument
    : (variableStart) => specialArgument
    | expression
    ;

//a smalltalk-style parameter to a positional parameter
//invocation
functionalArgument
    : functionalArgumentHeader functionalArgumentDefinition
    -> ^(NAMED_ARG functionalArgumentHeader? ^(ANON_METH functionalArgumentDefinition))
    ;
    
functionalArgumentHeader
    : parameterName
    -> ^(ARG_NAME parameterName)
    | 'case' '(' expressions ')'
    -> ^(CASE_ITEM expressions)
    ;

functionalArgumentDefinition
    : ( (formalParameterStart) => formalParameters )? 
      ( block | parExpression /*| literal | specialValue*/ )
    ;

specialArgument
    : (type|'local') memberName (containment|specifier)
    //| isCondition
    //| existsCondition
    ;

formalParameters
    : '(' (formalParameter (',' formalParameter)*)? ')'
    -> ^(FORMAL_PARAMETER_LIST ^(FORMAL_PARAMETER formalParameter)*)
    ;

//special rule for syntactic predicates
//be careful with this one, since it 
//matches "()", which can also be an 
//argument list
formalParameterStart
    : '(' ( userAnnotation* ( langAnnotation | formalParameterType LIDENTIFIER ) | ')' )
    ;
    
// FIXME: This accepts more than the language spec: named arguments
// and varargs arguments can appear in any order.  We'll have to
// enforce the rule that the ... appears at the end of the parapmeter
// list in a later pass of the compiler.
formalParameter
    : annotations? formalParameterType parameterName formalParameters*
      ( '->' type parameterName | '..' parameterName )? 
      specifier?
    ;

formalParameterType
    : (type|'void') '...'?
    ;

// Control structures.

condition
    : expression | existsCondition | nonemptyCondition | isCondition
    ;

existsCondition
    : 'exists' controlVariableOrExpression
    -> ^(EXISTS_EXPR controlVariableOrExpression)
    ;
    
nonemptyCondition
    : 'nonempty' controlVariableOrExpression
    -> ^(NONEMPTY_EXPR controlVariableOrExpression)
    ;

isCondition
    : 'is' type ( (memberName '=') => memberName specifier | expression )
    -> ^(IS_EXPR type memberName? specifier? expression?)
    ;

controlStructure
    : ifElse | switchCaseElse | whileStmt | doWhile | forFail | tryCatchFinally
    ;
    
ifElse
    : ifBlock elseBlock?
    -> ^(IF_STMT ifBlock elseBlock?)
    ;

ifBlock
    : 'if' '(' condition ')' block
    -> ^(CONDITION condition) ^(IF_TRUE block)
    ;

elseBlock
    : 'else' (ifElse | block)
    -> ^(IF_FALSE block? ifElse?)
    ;

switchCaseElse
    : switchHeader ( '{' cases '}' | cases )
    -> ^(SWITCH_STMT switchHeader cases)
    ;

switchHeader
    : 'switch' '(' expression ')'
    -> ^(SWITCH_EXPR expression)
    ;

cases 
    : caseItem+ defaultCaseItem?
    -> ^(SWITCH_CASE_LIST caseItem+ defaultCaseItem?)
    ;
    
caseItem
    : 'case' '(' caseCondition ')' block
    -> ^(CASE_ITEM caseCondition block)
    ;

defaultCaseItem
    : 'else' block
    -> ^(CASE_DEFAULT block)
    ;

caseCondition
    : expressions | isCaseCondition
    ;

expressions
    : expression (',' expression)*
    -> ^(EXPR_LIST expression+)
    ;

isCaseCondition
    : 'is' type
    -> ^(IS_EXPR type)
    ;

forFail
    : forBlock failBlock?
    -> ^(FOR_STMT forBlock failBlock?)
    ;

forBlock
    : 'for' '(' forIterator ')' block
    -> forIterator ^(LOOP_BLOCK block)
    ;

failBlock
    : 'fail' block
    -> ^(FAIL_BLOCK block)
    ;

forIterator
    : variable ('->' variable)? containment
    -> ^(FOR_ITERATOR variable+ containment)
    ;
    
containment
    : 'in' expression
    -> ^(FOR_CONTAINMENT expression)
    ;
    
doWhile
    : doBlock loopCondition ';'
    -> ^(WHILE_STMT doBlock loopCondition)
    ;

whileStmt
    : loopCondition whileBlock
    -> ^(WHILE_STMT loopCondition whileBlock)
    ;

loopCondition
    : 'while' '(' condition ')'
    -> ^(CONDITION condition)
    ;

whileBlock
    : block
    -> ^(WHILE_BLOCK block)
    ;

doBlock
    : 'do' block
    -> ^(DO_BLOCK block)
    ;

tryCatchFinally
    : tryBlock catchBlock* finallyBlock?
    -> ^(TRY_CATCH_STMT tryBlock catchBlock* finallyBlock?)
    ;

tryBlock
    : 'try' ('(' resource ')')? block
    -> ^(TRY_STMT resource? ^(TRY_BLOCK block))
    ;

catchBlock
    : 'catch' '(' variable ')' block
    -> ^(CATCH_STMT variable ^(CATCH_BLOCK block))
    ;

finallyBlock
    : 'finally' block
    -> ^(FINALLY_BLOCK block)
    ;

resource
    : controlVariableOrExpression
    -> ^(TRY_RESOURCE controlVariableOrExpression)
    ;

controlVariableOrExpression
    : (variableStart) => variable specifier 
    | expression
    ;

variable
    : (type|'local') memberName
    ;

//special rule for syntactic predicate
variableStart
    : variable ('in'|'=')
    ;

// Lexer

fragment
Digits
    : ('0'..'9')+
    ;

fragment 
Exponent    
    : ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+ 
    ;

fragment ELLIPSIS
    :   '...'
    ;

fragment RANGE
    :   '..'
    ;

fragment DOT
    :   '.'
    ;

fragment FLOATLITERAL :;
NATURALLITERAL
    : Digits 
      ( { input.LA(2) != '.' }? => '.' Digits Exponent? { $type = FLOATLITERAL; } )?
    | '.' ( '..' { $type = ELLIPSIS; } | '.'  { $type = RANGE; } | { $type = DOT; } )
    ;

CHARLITERAL
    :   '@' ( ~ NonCharacterChars | EscapeSequence )
    ;

fragment
NonCharacterChars
    :    ' ' | '\\' | '\t' | '\n' | '\f' | '\r' | '\b'
    ;

QUOTEDLITERAL
    :   '\'' StringPart '\''
    ;

SIMPLESTRINGLITERAL
    :   '"' StringPart '"'
    ;

fragment
NonStringChars
    :    '\\' | '"' | '\''
    ;

fragment
StringPart
    : ( ~ /* NonStringChars*/ ('\\' | '"' | '\'')
    | EscapeSequence) *
    ;
    
fragment
EscapeSequence 
    :   '\\' (
            'b' 
        |   't' 
        |   'n' 
        |   'f' 
        |   'r'
        |   's' 
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
    |   '//' ~('\n'|'\r')*
        {
            skip();
        }
    ;   

MULTI_COMMENT
    :   '/*'
        {
            $channel=HIDDEN;
        }
        (    ~('/'|'*')
        |    ('/' ~'*') => '/'
        |    ('*' ~'/') => '*'
        |    MULTI_COMMENT
        )*
        '*/'
        ;

ASSIGN
    :   'assign'
    ;
    
BREAK
    :   'break'
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

CONTINUE
    :   'continue'
    ;

DO
    :   'do'
    ;
    
ELSE
    :   'else'
    ;            

EXISTS
    :   'exists'
    ;

EXTENDS
    :   'extends'
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

SATISFIES
    :   'satisfies'
    ;

IMPORT
    :   'import'
    ;

INTERFACE
    :   'interface'
    ;

LOCAL
    :   'local'
    ;

NONE
    :   'none'
    ;

NULL
    :   'null'
    ;

NONEMPTY
    :   'nonempty'
    ;

GET
    :   'get'
    ;

SET
    :   'set'
    ;

RETURN
    :   'return'
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

SUBTYPE
    :   'subtype'
    ;

THROW
    :   'throw'
    ;

TRY
    :   'try'
    ;

RETRY
    : 'retry'
    ;

VOID
    :   'void'
    ;

WHILE
    :   'while'
    ;

LPAREN
    :   '('
    ;

RPAREN
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

EQ
    :   '='
    ;

RENDER
    :   '$'
    ;

NOT
    :   '!'
    ;

BITWISENOT
    :   '~'
    ;

QMARK
    :   '?'
    ;

COLON
    :   ':'
    ;
    
COLONEQ
    :   ':='
    ;

EQEQ
    :   '=='
    ;

IDENTICAL
    :   '==='
    ;

AND
    :   '&&'
    ;

OR
    :   '||'
    ;

IMPLIES
    :   '=>'
    ;

INCREMENT
    :   '++'
    ;

DECREMENT
    :   '--'
    ;

PLUS
    :   '+'
    ;

MINUS
    :   '-'
    ;

TIMES
    :   '*'
    ;

DIVIDED
    :   '/'
    ;

BITWISEAND
    :   '&'
    ;

BITWISEOR
    :   '|'
    ;

BITWISEXOR
    :   '^'
    ;

REMAINDER
    :   '%'
    ;

NOTEQ
    :   '!='
    ;

GT
    :   '>'
    ;

LT
    :   '<'
    ;        

GTEQ
    :   '>='
    ;

LTEQ
    :   '<='
    ;        

ENTRY
    :   '->'
    ;
    
COMPARE
    :   '<=>'
    ;
    
IN
    :   'in'
    ;

OUT
    :   'out'
    ;

IS
    :   'is'
    ;

HASH
    :   '#'
    ;

QUESDOT
    :    '?.'
    ;

STARDOT
    :    '*.'
    ;

POWER
    :    '**'
    ;

DOTEQ
    :   '.='
    ;

PLUSEQ
    :   '+='
    ;

MINUSEQ
    :   '-='
    ;

TIMESEQ
    :   '*='
    ;

DIVIDEDEQ
    :   '/='
    ;

BITWISEANDEQ
    :   '&='
    ;

BITWISEOREQ
    :   '|='
    ;

BITWISEXOREQ
    :   '^='
    ;

REMAINDEREQ
    :   '%='
    ;

QMARKEQ
    :   '?='
    ;

ANDEQ
    :   '&&='
    ;

OREQ
    :   '||='
    ;

PUBLIC
    :   'public'
    ;

MODULE
    :   'module'
    ;

PACKAGE
    :   'package'
    ;

PRIVATE
    :   'private'
    ;

ABSTRACT
    :   'abstract'
    ;

DEFAULT
    :   'default'
    ;

OVERRIDE
    :   'override'
    ;

OPTIONAL
    :   'optional'
    ;

MUTABLE
    :   'mutable'
    ;

EXTENSION
    :   'extension'
    ;

VOLATILE
    :   'volatile'
    ;

LIDENTIFIER 
    :   LIdentifierPart IdentifierPart*
    ;

UIDENTIFIER 
    :   UIdentifierPart IdentifierPart*
    ;

// FIXME: Unicode identifiers
fragment
LIdentifierPart
    :   '_'
    |   'a'..'z'
    ;       
                       
// FIXME: Unicode identifiers
fragment
UIdentifierPart
    :   'A'..'Z'
    ;       
                       
fragment 
IdentifierPart
    :   LIdentifierPart 
    |   UIdentifierPart
    |   '0'..'9'
    ;
