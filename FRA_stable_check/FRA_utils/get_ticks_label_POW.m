function Tick_label = get_ticks_label_POW(Ticks)

Tick_label = string.empty;
for i = 1:numel(Ticks)
    Num = digits_count(Ticks(i), -inf);
    if Num < 0
        Exp = fix(Num/3)*3;
    else
        Exp = ceil(Num/3)*3;
    end
    
    Exp = log10(Ticks(i));

    if is_int_num(Exp)
        if Exp ~= 0
            Tick_label(i) = sprintf("%d^{%d}", 10, Exp);
        else
            Tick_label(i) = sprintf("%d^{ }", Ticks(i));
        end
    else
        Tick_label(i) = "";
    end
end
end


function status = is_int_num(num)
    status = round(num) == num;
end