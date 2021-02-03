Definitions.

MONTH = [0-9]{2}
DAY = [0-9]{2}
MINUTE = [0-9]{2}
SECOND = [0-9]{2}
HOUR = [0-9]{2}
YEAR = [0-9]{4}

PLUS = \+
MINUS = \-
DIVIDE = \/
INTEGER = [0-9]+
UNIT = [smhdwMy]
WHITESPACE = [\s\t\n\r]
WORD = [a-zA-Z_][a-zA-Z0-9_]*
P_OPEN = \(
P_CLOSE = \)
COLON = \:

Rules.

([0-9]{4})(\-[0-9]{2})? : {token, {test, TokenLine, list_to_binary(TokenChars)}}.

{YEAR}{MINUS}{MONTH}{MINUS}{DAY}T{HOUR}{COLON}{MINUTE}{COLON}{SECOND} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D}T{h24}:{m}:{s}">>, [year, month, day, hour, minute, second], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH}{MINUS}{DAY}\s{HOUR}{COLON}{MINUTE}{COLON}{SECOND} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D} {h24}:{m}:{s}">>, [year, month, day, hour, minute, second], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH}{MINUS}{DAY}T{HOUR}{COLON}{MINUTE} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D}T{h24}:{m}">>, [year, month, day, hour, minute], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH}{MINUS}{DAY}\s{HOUR}{COLON}{MINUTE} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D} {h24}:{m}">>, [year, month, day, hour, minute], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH}{MINUS}{DAY}T{HOUR} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D}T{h24}">>, [year, month, day, hour], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH}{MINUS}{DAY}\s{HOUR} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D} {h24}">>, [year, month, day, hour], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH}{MINUS}{DAY} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}-{D}">>, [year, month, day], list_to_binary(TokenChars)}}.
{YEAR}{MINUS}{MONTH} : {token, {dt_parts, TokenLine, <<"{YYYY}-{M}">>, [year, month], list_to_binary(TokenChars)}}.
{YEAR} : {token, {dt_parts, TokenLine, <<"{YYYY}">>, [year], list_to_binary(TokenChars)}}.

{HOUR}{COLON}{MINUTE}{COLON}{SECOND} : {token, {dt_parts, TokenLine, <<"{h24}:{m}:{s}">>, [hour, minute, second], list_to_binary(TokenChars)}}.
{HOUR}{COLON}{MINUTE} : {token, {dt_parts, TokenLine, <<"{h24}:{m}">>, [hour, minute], list_to_binary(TokenChars)}}.

{INTEGER} : {token, {number, TokenLine, list_to_integer(TokenChars)}}.
{PLUS}   : {token, {'+', TokenLine}}.
{MINUS}  : {token, {'-', TokenLine}}.
{DIVIDE} : {token, {'/', TokenLine}}.
{UNIT} : {token, {unit, TokenLine, list_to_binary(TokenChars)}}.
{P_OPEN}    : {token, {'(', TokenLine}}.
{P_CLOSE}   : {token, {')', TokenLine}}.
{COLON} : {token, {':', TokenLine}}.
{WORD}  : {token, {word, TokenLine, list_to_binary(TokenChars)}}.
{WHITESPACE}+ : skip_token.


Erlang code.

