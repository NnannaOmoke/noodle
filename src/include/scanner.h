#ifndef NOODLE_SCANNER_H
#define NOODLE_SCANNER_H

typedef enum 
{

    TOKEN_LEFT_PAREN, TOKEN_RIGHT_PAREN,
    TOKEN_LEFT_BRACE, TOKEN_RIGHT_BRACE,
    TOKEN_COMMA, TOKEN_DOT, TOKEN_MINUS, TOKEN_PLUS,
    TOKEN_SEMICOLON, TOKEN_SLASH, TOKEN_STAR,

    TOKEN_BANG, TOKEN_BANG_EQUAL,
    TOKEN_EQUAL, TOKEN_EQUAL_EQUAL,
    TOKEN_GREATER, TOKEN_GREATER_EQUAL,
    TOKEN_LESS, TOKEN_LESS_EQUAL,

    TOKEN_IDENTIFIER, TOKEN_STRING, TOKEN_NUMBER,


    // TODO: ADD KEYWORDS
}TokenType;

typedef struct
{
    int line;
    const char* start;
    char* current;
} Scanner;

typedef struct
{
    TokenType type;
    const char* start;
    int length;
    int line;
} Token;

void initScanner(Scanner *scanner_obj, const char* source);

#endif