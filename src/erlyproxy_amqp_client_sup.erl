-module(erlyproxy_amqp_client_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    {ok, { {one_for_all, 0, 1}, [
        {
            erlyproxy_amqp_client, 
            {
               erlyproxy_amqp_client, 
                start_link, 
                []
            },
            transient,
            infinity,
            worker,
            [erlyproxy_amqp_client]
        }
    ]}}.