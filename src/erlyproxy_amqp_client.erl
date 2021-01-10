-module(erlyproxy_amqp_client).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2]).

-export([start_link/0]).
-export([request/2]).

-include_lib("amqp_client/include/amqp_client.hrl").

-compile({parse_transform, ejson_trans}).

-define(SERVER, ?MODULE).

-record(request, {target, action, payload}).
-record(response, {client, payload}).

-json({request, {string, "target"}, {string, "action"}, {string, "payload"}}).
-json({response, {string, "client"}, {string, "payload"}}).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_Args) ->
  application:ensure_started(amqp_client),

  {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
  {ok, Channel} = amqp_connection:open_channel(Connection),
  {ok, dict:store(channel, Channel, dict:new())}.

get_queue(State, Name) ->
  QueueName = <<"queue_", Name/binary >>,
  case dict:is_key(QueueName, State) of
    true -> {dict:fetch(QueueName, State), State};
    false ->
      #'queue.declare_ok'{queue = Queue} 
        = amqp_channel:call(dict:fetch(channel, State), #'queue.declare'{queue = Name}),
      get_queue(dict:store(QueueName, Queue, State), Name)
  end.

request(From, BinaryJsonString) ->
  gen_server:cast(?SERVER, {request, From, BinaryJsonString}).

handle_call(Request, _From, State) ->
  io:format("Unhandled call: ~p~n", [Request]),
  {reply, notok, State}.

handle_cast({request, Client, BinaryJsonString}, State) ->
  % Extract data
  {ok, Request} = from_json(BinaryJsonString, request),
  #request{target=Target, action=Action, payload=Payload} = Request,
  {ok, Message} = to_json(#response{client=pid_to_list(Client), payload=Payload}),
  % Post message
  {Queue, State1} = get_queue(State, utils:concat([Target, "_", Action], binary)),
  Publish = #'basic.publish'{exchange = <<>>, routing_key = Queue},
  Reponse = #amqp_msg{payload = Message},
  amqp_channel:cast(dict:fetch(channel, State), Publish, Reponse),
  {noreply, State};
handle_cast(Request, State) ->
  io:format("Unhandled cast: ~p~n", [Request]),
  {noreply, State}.