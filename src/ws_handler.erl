-module(ws_handler).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).


init(Req, State) ->
    io:format("websocket connection initiated~n~p~n~nstate: ~p~n", [Req, State]),
    {cowboy_websocket, Req, State}.

websocket_init(_) ->
    {ok, []}.


websocket_handle(Data, State) ->
    io:format("websocket data from client: ~p~n", [Data]),
    {ok, State}.

websocket_info(_Info, State) ->
    {ok, State}.

terminate(_Reason, Req, _State) ->
    io:format("websocket connection terminated~n~p~n", [maps:get(peer, Req)]),
    ok.
