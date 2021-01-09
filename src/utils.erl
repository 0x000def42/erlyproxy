-module(utils).

-export([concat/2]).

%% EXTERNAL

concat(Words, string) ->
    internal_concat(Words);
concat(Words, binary) ->
    list_to_binary(internal_concat(Words)).

%% INTERNAL

internal_concat(Elements) ->
    NonBinaryElements = [case Element of _ when is_binary(Element) -> binary_to_list(Element); _ -> Element end || Element <- Elements],
    lists:concat(NonBinaryElements).
