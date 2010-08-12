#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pa ebin

main(_) ->
  etap:plan(unknown),
  
  application:start(sasl),
  application:start(redis),

  %% Test flushdb first to ensure we have a clean db
  etap:is(
    redis:q([flushdb]),
    {ok, <<"OK">>},
    "+ status reply"
  ),

  etap:is(
    redis:q([foobar]),
    {error, <<"ERR unknown command 'FOOBAR'">>},
    "- status reply"
  ),

  etap:is(
    redis:q([set, "foo", "bar"]),
    {ok, <<"OK">>},
    "test status reply"
  ),

  etap:is(
    redis:q([get, "foo"]),
    {ok, <<"bar">>},
    "test bulk reply"
  ),

  etap:is(
    redis:q([get, "notakey"]),
    {ok, null},
    "test bulk reply with -1 length"
  ),

  etap:is(
    redis:keys("notamatch"),
    [],
    "test bulk reply with 0 length"
  ),

  redis:q([set, "abc", "123"]),
  etap:is(
    redis:q([mget, "foo", "abc"]),
    [{ok, <<"bar">>}, {ok, <<"123">>}],
    "multi bulk reply"
  ),

  etap:is(
    redis:keys(),
    [<<"foo">>, <<"abc">>],
    "keys sugar"
  ),

  ok.
