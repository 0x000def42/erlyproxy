-module(amqp_client).
-compile({parse_transform, ejson_trans}).
-behaviour(gen_server).

-record(request, {target, action, payload}).
-record(response, {client, payload}).
-json({request, {string, "target"}, {string, "action"}, {string, "payload"}}).

-export([init/1, handle_call/3, handle_cast/2]).

-export([start_link/0]).
-export([request/2]).

-define(SERVER, ?MODULE).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_Args) ->
  {ok, dict:new()}.

request(From, BinaryJsonString) ->
  gen_server:cast(?SERVER, {request, From, BinaryJsonString}).

handle_call(Request, _From, State) ->
  io:format("Unhandled call: ~p~n", [Request]),
  {reply, notok, State}.

handle_cast({request, Client, BinaryJsonString}, State) ->
  {ok, Request} = from_json(BinaryJsonString, request),
  #request{target=Target, action=Action, payload=Payload} = Request,
  % TODO: Post message to queue here
  {noreply, State};
handle_cast(Request, State) ->
  io:format("Unhandled cast: ~p~n", [Request]),
  {noreply, State}.