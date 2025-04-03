
clc

Delata = 0.12345678
Delta_limit = 0.000100

DISP_DELTA(Delata, Delta_limit, '1')



function DISP_DELTA(Delta, Delta_limit, units)
    arguments
        Delta
        Delta_limit
        units {mustBeMember(units, ["1", "%", "ppm"])} = "1"
    end
    switch units
        case "1"
            mult = 1;
        case "%"
            mult = 100;
        case "ppm"
            mult = 1e6;
    end
    Delta = Delta * mult;
    Delta_limit = Delta_limit * mult;
    [~, Fmt] = digits_count(Delta_limit, 1);
    disp(['Delta: ' num2str(Delta, Fmt) ' | ' num2str(Delta_limit, Fmt)]);
end

function [n, fmt] = digits_count(a, min_n)
    arguments
        a (1,1) {mustBeNumeric(a)}
        min_n (1,1) {mustBeNumeric(min_n)} = 0
    end
    
    n = -ceil(log10(a));
    while (a*10^n - round(a*10^n) ~= 0) && n < 6
        n = n + 1;
    end

    if n < min_n
        n = min_n;
    end

    fmt = ['%.' num2str(n) 'f'];
end