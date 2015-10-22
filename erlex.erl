-module(erlex).

-export([
	erlex/2,
	test/0
	]).

%% --------------------------------------------------------------------------
%% Code:     string()
%% LexSpec: [ {REString, fun TextToTokenFunc/1, fun TextToValueFunc/1}, ... ]
%% --------------------------------------------------------------------------

erlex(Code, LexSpec) -> lex(Code, compile_lexspec(LexSpec), []).
lex([], _CompLexSpec, TokenList) -> lists:reverse(TokenList);
lex(Code, CompLexSpec, TokenList) ->
	case match(Code, CompLexSpec) of
		nomatch -> {syntax_error, Code};
		{NewCode, Token, Text, Value} ->
			lex(NewCode, CompLexSpec, [{Token, Text, Value} | TokenList])
	end.

compile_lexspec(LexSpec) -> compile_lexspec(LexSpec, []).
compile_lexspec([], CompLexSpec) -> lists:reverse(CompLexSpec);
compile_lexspec([{RE, TTTF, TTVF} | RETail], CompLexSpec) ->
	NRE = string:concat(string:concat("^\\s*", RE), "\\s*"),
	{ok, CRE} = re:compile(NRE),
	compile_lexspec(RETail, [{CRE,TTTF,TTVF} | CompLexSpec]).

match(_Code, []) -> nomatch;
match(Code, [{CRE, TTTF, TTVF} | CompLexSpecTail]) ->
	case re:run(Code, CRE) of
		{match, [{Start, Len}]} ->
			Text = string:strip(string:substr(Code, Start + 1, Len)),
			{string:substr(Code, Start + Len + 1), TTTF(Text), Text, TTVF(Text)};
		nomatch -> match(Code, CompLexSpecTail)
	end.


%% ------------------------------------------------------------------
%% Tests
%% ------------------------------------------------------------------

test() ->
	LexSpec = [
		{"\\d+", fun(_S) -> number end, fun test_number_to_value/1},
		{"\\+",  fun test_op_token/1,   fun(S) -> S end},
		{"\\-",  fun test_op_token/1,   fun(S) -> S end},
		{"\\*",  fun test_op_token/1,   fun(S) -> S end},
		{"\\/",  fun test_op_token/1,   fun(S) -> S end},
		{"\\^",  fun test_op_token/1,   fun(S) -> S end}
	],
	erlex("1 2 + / 3 ^ 2", LexSpec).


test_op_token(S) ->
	case S of
		"+" -> add;
		"-" -> subtract;
		"*" -> multiply;
		"/" -> divide;
		"^"  -> exponentiate
	end.

test_number_to_value(S) ->
	{I,_R} = string:to_integer(S),
	I.