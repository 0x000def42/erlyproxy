-module(ws_handler).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).


init(Req, State) ->
    {cowboy_websocket, Req, State}.

websocket_init(_State) ->
    {ok, []}.

websocket_handle(Data, State) ->
    Pid = self(),
    amqp_client:request(Pid, Data),
    {ok, State}.

websocket_info({response, Msg}, State) ->
    {reply, {text, Msg}, State};
websocket_info(_Info, State) ->
 	{ok, State}.

terminate(_Reason, Req, _State) ->
    ok.
