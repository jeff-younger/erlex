# erlex
Simple erlang lexical analyzer.

## Description

`erlex()` takes executable code in the form of a string and a lexical specification defined as a list of tuples:

```Erlang
[{REString, fun TextToTokenFunc/1, fun TextToValueFunc/1}, ... ]
```

REString is just a regular expression that matches a substring corresponding to a lexical token. TextToTokenFunc is a function that takes the substring and returns some data structure that represents the token. TextToValueFunc is a function takes the substring and returns a value to be used later by the parser.

## Usage

Here's some test code. `erlex()` is the function that does the work.

```Erlang
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
```

The output is a list of Erlang tuples containing the lexical tokens and values.

```Erlang
[{number,"1",1},{number,"2",2},{add,"+","+"},{divide,"/","/"},{number,"3",3},{exponentiate,"^","^"},{number,"2",2}]
```

## Next Steps

1. Write a sequential parser, `erlparse()`. The tough part is coming up with an Erlang representation of the grammar tha wil support step three below.
2. Write a parallel `erlex()`, called `perlex()`, that can maintain the proper sequence of token tuples.
3. Write a parellel parser, called `perlparse()`. Make it general enough to either generate p-code or dynamically execute the code. Support streaming lexical tokens from either `erlex()` or `perlex()` to the parser.
4. Define the sequential versons as a behavior, `gen_erlparse,` with callbacks.
5. Define the parallel version as a behavior, `gen_perlparse`, with callbacks.