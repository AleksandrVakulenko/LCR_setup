function Tick_label = get_ticks_label_SI(Ticks)

Tick_label = string.empty;
for i = 1:numel(Ticks)
    Num = digits_count(Ticks(i), -inf);
%     disp([num2str(Ticks(i), '%0.9f') ' ' num2str(Num)])
    if Num < 0
        Exp = fix(Num/3)*3;
    else
        Exp = ceil(Num/3)*3;
    end

    [Exp, Unit] = get_exp_unit(Exp);

    Tick_label(i) = sprintf("%d%s", round(Ticks(i)*10^Exp), Unit);
end
end


function [Exp, Unit] = get_exp_unit(Exp)
if Exp > 18
    Exp = 18;
end
if Exp < -12
    Exp = -12;
end
switch Exp
    case 18
        Unit = "a";
    case 15
        Unit = "f";
    case 12
        Unit = "p";
    case 9
        Unit = "n";
    case 6
        Unit = "u";
    case 3
        Unit = "m";
    case 0
        Unit = "";
    case -3
        Unit = "k";
    case -6
        Unit = "M";
    case -9
        Unit = "G";
    case -12
        Unit = "T";
    otherwise
        error('placeholder')
end
end