# erlex
Simple erlang lexical analyzer.

erlex takes executable code in the form of a string and a lexical specification defined as a list of tuples:

```Erlang
[{REString, fun TextToTokenFunc/1, fun TextToValueFunc/1}, ... ]
```