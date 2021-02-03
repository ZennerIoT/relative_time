Terminals '+' '-' '/' '(' ')' number word unit set_date.
Nonterminals datetime interval marker.
Rootsymbol datetime.

Left 500 '+' '-'.
Right 500 '/'.

datetime -> set_date : set_date('$1').
datetime -> '(' datetime ')' : '$2'.
interval -> number unit : {interval, extract_context('$1'), [extract_token('$1'), extract_unit('$2')]}.
interval -> set_date unit : set_date_to_interval('$1', '$2').
datetime -> datetime '+' interval : {'+', extract_context('$2'), ['$1', '$3']}.
datetime -> datetime '-' interval : {'-', extract_context('$2'), ['$1', '$3']}.
datetime -> datetime '/' unit : {'/', extract_context('$2'), ['$1', extract_unit('$3')]}.
datetime -> marker : '$1'.
marker -> word : {marker, extract_context('$1'), [extract_token('$1')]}.

Erlang code.
extract_context({_Token, _Line, Ctx, _Value}) -> Ctx;
extract_context({_Token, _Line, Ctx}) -> Ctx.
extract_token({_Token, _Line, _Ctx, Value}) -> Value.
extract_unit({unit, _Line, _Ctx, Value}) -> 
  case Value of
    <<"s">> -> second;
    <<"m">> -> minute;
    <<"h">> -> hour;
    <<"d">> -> day;
    <<"w">> -> week;
    <<"M">> -> month;
    <<"y">> -> year
  end.
set_date({set_date, _Line, Ctx, Sets}) -> {set_date, Ctx, [Sets]}.
set_date_to_interval({set_date, _Line, Ctx, [{hour, Amount}]}, Unit) -> {interval, Ctx, [Amount, extract_unit(Unit)]}.