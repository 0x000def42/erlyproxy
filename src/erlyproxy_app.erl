%%%-------------------------------------------------------------------
%% @doc ws public API
%% @end
%%%-------------------------------------------------------------------

-module(erlyproxy_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% API

start(_StartType, _StartArgs) ->
    case os:getenv("PORT") of
        false ->
            {_Status, Port} = application:get_env(ws, port);
        Other ->
            Port = Other
    end,        

    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", ws_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, list_to_integer(Port)}], #{
        env => #{dispatch => Dispatch}
    }),

    erlyproxy_sup:start_link(),
    amqp_client_sup:start_link().

stop(_State) ->
    ok.

%% Internal functions
