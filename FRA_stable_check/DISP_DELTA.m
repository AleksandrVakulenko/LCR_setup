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
    disp(['Delta: ' num2str(Delta, Fmt) ' | ' ...
        num2str(Delta_limit, Fmt) ...
        ' [' char(units) ']']);
end