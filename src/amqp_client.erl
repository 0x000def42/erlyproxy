-module(amqp_client).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2]).

-export([start_link/0]).
-export([request/2]).

-define(SERVER, ?MODULE).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_Args) ->
  {ok, dict:new()}.

request(From, Data) ->
  gen_server:cast(?SERVER, {request, From, Data}).

handle_call(Request, _From, State) ->
  io:format("Unhandled call: ~p~n", [Request]),
  {reply, notok, State}.

handle_cast(Request, State) ->
  io:format("Unhandled cast: ~p~n", [Request]),
  {noreply, State}.