function Symbol = getSigSymbol(P)
% identify symbol to plot for sig star

if P < .1 && P > .05
    Symbol = ' ';
elseif P <= .05 && P > .01
    Symbol = '*';
elseif P <= .01 && P > .001
    Symbol = '**';
elseif P <= .001
    Symbol = '***';
else
    Symbol = '';
end