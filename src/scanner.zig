const std = @import("std");
const static_map = std.static_string_map;

// by my understanding, turn this whole file into a struct
const Scanner = @This();

line: u8,
position: u8,
source_text: *[]const u8,

// the source_text should point to memory already allocated
// the allocation happens in a seperate utils file

pub fn init(source_text_ptr: *[]const u8) Scanner {
    return .{
        .line = 1,
        .position = 0,
        .source_text = source_text_ptr,
    };
}

fn strcmp(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

const TokenType = enum {
    TOKEN_EOF,
    TOKEN_LESS_EQUAL,
    TOKEN_LESS_COMP,
    TOKEN_EQUAL_ASS,
    TOKEN_EQUAL_EQUAL,
    TOKEN_GREATER_EQUAL,
    TOKEN_GREATER_COMP,
    TOKEN_PLUS_PLUS,
    TOKEN_PLUS_EQUAL,
    TOKEN_PLUS,
    TOKEN_MINUS_MINUS,
    TOKEN_MINUS_EQUAL,
    TOKEN_ARROW,
    TOKEN_MINUS,
    TOKEN_TRUEDIV,
    TOKEN_BANG_EQUAL,
    TOKEN_BANG,
    TOKEN_STAR,
    TOKEN_STAR_EQUAL,
    TOKEN_AMPERSAND_EQUAL,
    TOKEN_AMPERSAND,
    TOKEN_PIPE,
    TOKEN_PIPE_EQUAL,
    TOKEN_LPAREN,
    TOKEN_RPAREN,
    TOKEN_LCURLY,
    TOKEN_RCURLY,
    TOKEN_LSQUARE,
    TOKEN_RSQUARE,
    TOKEN_DOT,
    TOKEN_COMMA,
    TOKEN_COLON,
    TOKEN_CARET,
    TOKEN_UNDERSCORE_UNIT,
    TOKEN_NUMERIC_LIT,
    TOKEN_ID,
    TOKEN_ERROR,
};

const keywords = static_map.StaticStringMapWithEql(TokenType, strcmp).initComptime(&.{ .{ "if", TokenType.TOKEN_IF }, .{ "else", TokenType.TOKEN_ELSE }, .{ "while", TokenType.TOKEN_WHILE }, .{ "return", TokenType.TOKEN_RETURN }, .{ "for", TokenType.TOKEN_FOR }, .{ "in", TokenType.TOKEN_IN }, .{ "as", TokenType.TOKEN_AS }, .{ "not", TokenType.TOKEN_NOT }, .{ "fn", TokenType.TOKEN_FN }, .{ "lambda", TokenType.TOKEN_LAMBDA }, .{ "or", TokenType.TOKEN_OR }, .{ "and", TokenType.TOKEN_AND }, .{ "int", TokenType.TOKEN_INT }, .{ "i16", TokenType.TOKEN_I16 }, .{ "u16", TokenType.TOKEN_U16 }, .{ "i32", TokenType.TOKEN_I32 }, .{ "u32", TokenType.TOKEN_U32 }, .{ "float", TokenType.TOKEN_FLOAT }, .{ "f32", TokenType.TOKEN_F32 }, .{ "f64", TokenType.TOKEN_F64 }, .{ "char", TokenType.TOKEN_CHAR }, .{ "any", TokenType.TOKEN_ANY }, .{ "str", TokenType.TOKEN_STR }, .{ "array", TokenType.TOKEN_ARRAY }, .{ "tuple", TokenType.TOKEN_TUPLE }, .{ "list", TokenType.TOKEN_LIST }, .{ "hashmap", TokenType.TOKEN_HASHMAP }, .{ "null", TokenType.TOKEN_NULL }, .{ "unit", TokenType.TOKEN_UNIT }, .{ "let", TokenType.TOKEN_LET }, .{ "mut", TokenType.TOKEN_MUT }, .{ "rec", TokenType.TOKEN_REC }, .{ "field", TokenType.TOKEN_FIELD }, .{ "type", TokenType.TOKEN_TYPE }, .{ "of", TokenType.TOKEN_OF }, .{ "union", TokenType.TOKEN_UNION }, .{ "opt", TokenType.TOKEN_OPT }, .{ "callable", TokenType.TOKEN_CALLABLE }, .{ "match", TokenType.TOKEN_MATCH } });

const Token = struct {
    line: u8,
    token_type: TokenType,
    length: u8,
    // where the variable itself starts
    start_index: u8,
    // write a TokenType enum
};
fn getKeyWordType(id: []const u8) TokenType {
    return keywords.get(id) orelse TokenType.TOKEN_ID;
}

// TODO: move all of this into a useful utils file
fn advance(self: *Scanner) void {
    self.position += 1;
}

fn peek(self: *Scanner) void {
    return self.position + 1;
}

fn jump(self: *Scanner, times: u8) void {
    for (0..times) |_| {
        self.advance();
    }
}

fn isAtEof(self: *Scanner) bool {
    return self.position == self.source_text.*.len;
}

//is alphabet
fn isalpha(char: u8) bool {
    if ((char >= 'a' and char <= 'z') or (char >= 'A' and char <= 'Z')) {
        return true;
    }
    return false;
}

fn isnumeric(char: u8) bool {
    if (char >= '0' and char <= '9') {
        return true;
    }
    return false;
}

fn isalnum(char: u8) bool {
    if (isalpha(char) or isnumeric(char)) {
        return true;
    }
    return false;
}

// NOTE: THIS FUNCTION WORKS WELL CUZ OF ASCII ENCODING
fn wrapper(char: u8) u8 {
    return std.ascii.toLower(char);
}

fn lower(char: u8) !u8 {
    if (char >= 'a' and char <= 'z') {
        return char;
    } else if (char >= 'A' and char <= 'Z') {
        return char - 'A' + 'a';
    } else {
        return error.NotALetter; // TODO: handle this properly later
    }
}

fn parse_id(self: *Scanner) Token {
    const beginning = self.position;
    const s_text = self.source_text.*;
    while (isalnum(s_text[self.position]) or s_text[self.position] == '_') {
        advance();
    }

    return getKeyWordType(s_text[beginning .. self.position + 1]);
}

fn parse_num(self: *Scanner) Token {
    const beginning = self.position;
    // parse the first part
    const s_text = self.source_text.*;
    var i: usize = 0;
    while (isnumeric(s_text[self.position])) : (i += 1) {
        advance();
    }

    // parse the fractional part
    if (s_text[self.position] == '.') {
        advance();
        while (isnumeric(s_text[self.position])) : (i += 1) {
            advance();
        }
    }

    // parse the scientific part
    if (lower(s_text[self.position]) == 'e') {
        i += 1;
        advance();

        // so this will cause the scanner to stop at something like 12.34e in 12.34e+opr
        if (s_text[self.position] == '+' or s_text[self.position] == '-') {
            if (isnumeric(s_text[peek()])) {
                i += 1;
                advance();
            }
        }

        if (isnumeric(s_text[self.position])) {
            while (s_text[self.position]) : (i += 1) {
                advance();
            }
        }
    }
    return Token{ .token_type = TokenType.TOKEN_NUMERIC_LIT, .length = i, .line = self.line, .start_index = beginning };
}
pub fn emitToken(self: *Scanner) Token {
    const s_text = self.source_text.*;

    while (!isAtEof()) {
        const char = s_text[self.position]; // get the current position

        const beginning = self.position;
        const jmp_val = (peek() + 1) - beginning; // most composite characters are of size 2
        switch (char) {
            '<' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_LESS_EQUAL, .line = self.line, .start_index = beginning, .length = jmp_val };
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_LESS_COMP, .line = self.line, .start_index = beginning, .length = 1 };
                }
            },

            '=' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_EQUAL_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_EQUAL_ASS, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '>' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_GREATER_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_GREATER_COMP, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '-' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_MINUS_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else if (s_text[peek()] == '-') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_MINUS_MINUS, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_MINUS, .length = 1, .line = self.line, .start_index = beginning };
                }
            },

            '+' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_PLUS_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else if (s_text[peek()] == '+') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_PLUS_PLUS, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_PLUS, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '/' => {
                if (s_text[peek()] == '/') {
                    advance();
                    while (s_text[self.position] != '\n') {
                        advance();
                    }

                    // we encountered a new line
                    self.line += 1;
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_TRUEDIV, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '!' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_BANG_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    return Token{ .token_type = TokenType.TOKEN_BANG, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '*' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_STAR_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    return Token{ .token_type = TokenType.TOKEN_STAR, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '&' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_AMPERSAND_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    return Token{ .token_type = TokenType.TOKEN_AMPERSAND, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '|' => {
                if (s_text[peek()] == '=') {
                    jump(jmp_val);
                    return Token{ .token_type = TokenType.TOKEN_PIPE_EQUAL, .length = jmp_val, .line = self.line, .start_index = beginning };
                } else {
                    return Token{ .token_type = TokenType.TOKEN_PIPE, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '(' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_LPAREN, .length = 1, .line = self.line, .start_index = beginning };
            },
            ')' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_RPAREN, .length = 1, .line = self.line, .start_index = beginning };
            },
            '{' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_LCURLY, .length = 1, .line = self.line, .start_index = beginning };
            },
            '}' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_RCURLY, .length = 1, .line = self.line, .start_index = beginning };
            },
            '[' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_LSQUARE, .length = 1, .line = self.line, .start_index = beginning };
            },
            ']' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_RSQUARE, .length = 1, .line = self.line, .start_index = beginning };
            },
            '.' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_DOT, .length = 1, .line = self.line, .start_index = beginning };
            },
            ',' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_COMMA, .length = 1, .line = self.line, .start_index = beginning };
            },
            ':' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_COLON, .length = 1, .line = self.line, .start_index = beginning };
            },

            '^' => {
                advance();
                return Token{ .token_type = TokenType.TOKEN_CARET, .length = 1, .line = self.line, .start_index = beginning };
            },
            '_' => {
                if (isalpha(s_text[peek()])) {
                    return parse_id();
                } else {
                    advance();
                    return Token{ .token_type = TokenType.TOKEN_UNDERSCORE_UNIT, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
            '\t', ' ', '\r' => {
                advance();
            },
            '\n' => {
                advance();
                self.line += 1;
            },
            // handles ids, keywords and error tokens
            else => {
                if (isalpha(char)) {
                    parse_id();
                } else if (isnumeric(char)) {
                    parse_num();
                } else {
                    // return an error Token
                    // reported by the scanner
                    return Token{ .token_type = TokenType.TOKEN_ERROR, .length = 1, .line = self.line, .start_index = beginning };
                }
            },
        }
    }
}
