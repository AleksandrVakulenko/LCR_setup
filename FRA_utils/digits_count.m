function [n, fmt] = digits_count(a, min_n)
    arguments
        a (1,1) {mustBeNumeric(a)}
        min_n (1,1) {mustBeNumeric(min_n)} = 0
    end
    
    n = -floor(log10(a));
    while (a*10^n - round(a*10^n) ~= 0) && n < 6
        n = n + 1;
    end

    if n < min_n
        n = min_n;
    end

    fmt = ['%.' num2str(n) 'f'];
end