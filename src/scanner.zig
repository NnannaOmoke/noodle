const std = @import("std");
const static_map = std.static_string_map;
const ascii = std.ascii;
// by my understanding, turn this whole file into a struct
const Scanner = @This();

line: u8,
position: u8,
source_text: []const u8, // this is better cuz it allows to you have proper array slices

// the source_text should point to memory already allocated
// the allocation happens in a seperate utils file

pub fn init(source_text_ptr: []const u8) Scanner {
    return .{
        .line = 1,
        .position = 0,
        .source_text = source_text_ptr,
    };
}

fn strcmp(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

// TODO: move all of this into a useful utils file
fn advance(self: *Scanner) void {
    self.position += 1;
}

fn peek(self: *Scanner) u8 {
    return self.position + 1;
}

fn canPeekNext(self: *Scanner) bool {
    return !(self.peek() >= self.source_text.len);
}

fn match(self: *Scanner, char: u8) bool {
    // return self.source_text[self.position] == char;
    if (self.canPeekNext()) {
        if (self.source_text[self.peek()] == char) {
            self.advance();
            return true;
        }
    }
    return false;
}

fn isAtEof(self: *Scanner) bool {
    return self.position > self.source_text.len;
}
fn parse_num(self: *Scanner) Token {
    const start_pos = self.position;

    // parse the first part of the number
    while (ascii.isDigit(self.source_text[self.position]) and self.canPeekNext()) {
        self.advance();
    }

    // parse the fractional part
    if (self.source_text[self.position] == '.') {
        self.advance();
        while (ascii.isDigit(self.source_text[self.position]) and self.canPeekNext()) {
            self.advance();
        }
    }

    // parse the scientific part
    if (ascii.toLower(self.source_text[self.position]) == 'e') {
        if (self.canPeekNext()) {
            self.advance();
            if (self.source_text[self.position] == '+' or self.source_text[self.position] == '-') {
                self.advance();
            }
        }

        // reads ahead by one character past the number
        while (ascii.isDigit(self.source_text[self.position]) and self.canPeekNext()) {
            self.advance();
        }
        // this will cause the scanner to stop at something like 12.34e in 12.34e+opt
    }

    return Token{ .token_type = TokenType.TOKEN_NUMERIC_LIT, .length = self.position - start_pos, .line = self.line, .start_index = start_pos };
}

fn getKeyWordType(id: []const u8) TokenType {
    return keywords.get(id) orelse TokenType.TOKEN_ID;
}

// TODO: write this out
fn parse_id(self: *Scanner) Token {
    const start_pos = self.position;
    while (ascii.isAlphanumeric(self.source_text[self.position]) and self.canPeekNext()) {
        advance();
    }

    return Token{ .token_type = getKeyWordType(self.source_text[start_pos .. self.position + 1]), .length = self.position - start_pos, .line = self.line, .start_index = start_pos };
}

pub fn emitToken(self: *Scanner) Token {
    // must be referenced as a slice apparently

    while (true) {
        if (self.isAtEof()) {
            break;
        }

        const char = self.source_text[self.position];
        const start_pos = self.position;
        switch (char) {
            '<' => {
                if (self.canPeekNext()) // i can see the next character
                {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_LESS_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_LESS_COMP, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.TOKEN_LESS_COMP, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '>' => {
                if (self.canPeekNext()) {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_GREATER_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_GREATER_COMP, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.TOKEN_GREATER_COMP, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '-' => {
                if (self.canPeekNext()) {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_MINUS_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else if (self.match('-')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_MINUS_MINUS, .length = 2, .line = self.line, .start_index = start_pos };
                    } else if (self.match('>')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_ARROW, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_MINUS, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.TOKEN_MINUS, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '+' => {
                if (self.canPeekNext()) {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_PLUS_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else if (self.match('+')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_PLUS_PLUS, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_PLUS, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.TOKEN_PLUS, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '!' => {
                if (self.canPeekNext()) {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_BANG_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_BANG, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.TOKEN_BANG, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '*' => {
                if (self.canPeekNext()) {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_STAR_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_STAR, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.TOKEN_STAR, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '/' => {
                if (self.canPeekNext()) {
                    if (self.match('/')) {
                        while (self.source_text[self.position] != '\n' and !self.isAtEof()) {
                            advance();
                        }
                        self.line += 1; // we found a new line
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_SLASH, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    return Token{ .token_type = TokenType.TOKEN_SLASH, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '|' => {
                if (self.canPeekNext()) {
                    if (self.match('=')) {
                        self.advance();
                        return Token{ .token_type = TokenType.TOKEN_PIPE_EQUAL, .length = 2, .line = self.line, .start_index = start_pos };
                    } else {
                        return Token{ .token_type = TokenType.TOKEN_PIPE, .length = 1, .line = self.line, .start_index = start_pos };
                    }
                } else {
                    self.advance();
                    return Token{ .token_type = TokenType.PIPE, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
            '(' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_LPAREN, .length = 1, .line = self.line, .start_index = start_pos };
            },
            ')' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_RPAREN, .length = 1, .line = self.line, .start_index = start_pos };
            },
            '{' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_LCURLY, .length = 1, .line = self.line, .start_index = start_pos };
            },
            '}' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_RCURLY, .length = 1, .line = self.line, .start_index = start_pos };
            },
            '[' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_LSQUARE, .length = 1, .line = self.line, .start_index = start_pos };
            },
            ']' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_RSQUARE, .length = 1, .line = self.line, .start_index = start_pos };
            },
            '.' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_DOT, .length = 1, .line = self.line, .start_index = start_pos };
            },
            ',' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_COMMA, .length = 1, .line = self.line, .start_index = start_pos };
            },
            ':' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_COLON, .length = 1, .line = self.line, .start_index = start_pos };
            },
            '^' => {
                self.advance();
                return Token{ .token_type = TokenType.TOKEN_CARET, .length = 1, .line = self.line, .start_index = start_pos };
            },
            else => {
                // handle white space
                if (ascii.isWhitespace(char)) {
                    if (char == '\n') {
                        self.line += 1;
                    }
                    self.advance();
                } else if (ascii.isAlphabetic(char) or char == '_') {
                    return parse_id();
                } else if (ascii.isDigit(char)) {
                    return parse_num();
                } else {
                    return Token{ .token_type = TokenType.TOKEN_ERROR, .length = 1, .line = self.line, .start_index = start_pos };
                }
            },
        }
    }
    // we are at the end of the file
    return Token{ .token_type = TokenType.TOKEN_EOF, .length = 1, .line = self.line, .start_index = self.position };
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
    TOKEN_SLASH,
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

// compile time hashmap to search for keywords
const keywords = static_map.StaticStringMapWithEql(TokenType, strcmp).initComptime(&.{ .{ "if", TokenType.TOKEN_IF }, .{ "else", TokenType.TOKEN_ELSE }, .{ "while", TokenType.TOKEN_WHILE }, .{ "return", TokenType.TOKEN_RETURN }, .{ "for", TokenType.TOKEN_FOR }, .{ "in", TokenType.TOKEN_IN }, .{ "as", TokenType.TOKEN_AS }, .{ "not", TokenType.TOKEN_NOT }, .{ "fn", TokenType.TOKEN_FN }, .{ "lambda", TokenType.TOKEN_LAMBDA }, .{ "or", TokenType.TOKEN_OR }, .{ "and", TokenType.TOKEN_AND }, .{ "int", TokenType.TOKEN_INT }, .{ "i16", TokenType.TOKEN_I16 }, .{ "u16", TokenType.TOKEN_U16 }, .{ "i32", TokenType.TOKEN_I32 }, .{ "u32", TokenType.TOKEN_U32 }, .{ "float", TokenType.TOKEN_FLOAT }, .{ "f32", TokenType.TOKEN_F32 }, .{ "f64", TokenType.TOKEN_F64 }, .{ "char", TokenType.TOKEN_CHAR }, .{ "any", TokenType.TOKEN_ANY }, .{ "str", TokenType.TOKEN_STR }, .{ "null", TokenType.TOKEN_NULL }, .{ "unit", TokenType.TOKEN_UNIT }, .{ "const", TokenType.TOKEN_CONST }, .{ "var", TokenType.TOKEN_VAR }, .{ "rec", TokenType.TOKEN_REC }, .{ "field", TokenType.TOKEN_FIELD }, .{ "type", TokenType.TOKEN_TYPE }, .{ "of", TokenType.TOKEN_OF }, .{ "union", TokenType.TOKEN_UNION }, .{ "opt", TokenType.TOKEN_OPT }, .{ "callable", TokenType.TOKEN_CALLABLE }, .{ "match", TokenType.TOKEN_MATCH } });
const Token = struct {
    line: u8,
    token_type: TokenType,
    length: u8,
    // where the variable itself starts
    start_index: u8,
    // write a TokenType enum
};

// TESTS
// fn print(comptime fmt: []const u8, args: anytype) !void {
//     var stdout_writer = std.io.getStdOut().writer();
//     try stdout_writer.print(fmt, args);
// }

// test "test init scanner" {
//     const test_str = "hello world!\n";
//     const myscanner: Scanner = init(test_str);
//     try print("Line: {}, Position: {}\n", .{ myscanner.line, myscanner.position });
// }

// // these are dumb looking tests i know
// test "emit single or numerous token" {
//     const l = "<";
//     const le = "<=";
//     var myscanner: Scanner = init(l);
//     var myscanner2: Scanner = init(le);
//     const token = myscanner.emitToken();
//     const token2 = myscanner2.emitToken();
//     try print("Token: length {}, line {}, start {}\n", .{ token.length, token.line, token.start_index });
//     try print("Token: length {}, line {}, start {}\n", .{ token2.length, token2.line, token2.start_index });
// }
