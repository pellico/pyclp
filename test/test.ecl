:- module(test).
:- import pyclp.
:- export test/2.
test(A,B):- call_python_function("p_func",[A,B]).
