function Ticks = gen_log_tick(Range, Grid)
    arguments
        Range {mustBeNumeric(Range)}
        Grid {mustBeNumeric(Grid)} = [1, 2, 5]
    end
    
    Min = Range(1);
    Max = Range(2);
    if Min > Max
        tmp = Min;
        Min = Max;
        Max = tmp;
        warning('swap min and max')
    elseif Min == Max
        error('Range(1) must be < Range(2)')
    end
    
    Exp_start = floor(log10(Min));
    Exp_end = ceil(log10(Max));
    Exp_range = Exp_start:Exp_end;
    
    Ticks = zeros(1, numel(Grid)*numel(Exp_range));
    k = 0;
    for i = Exp_range
        for j = 1:numel(Grid)
            k = k + 1;
            Ticks(k) = Grid(j)*10^i;
        end
    end
    Ticks(Ticks < Min) = [];
    Ticks(Ticks > Max) = [];
end