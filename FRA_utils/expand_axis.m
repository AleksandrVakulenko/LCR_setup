

%FIXME учесть логарифмический масштаб
%FIXME учесть выбор оси

function expand_axis(ax_frame, ax, method, expand_value)
arguments
    ax_frame
    ax {mustBeMember(ax, ["x", "y"])} = "y"
    method {mustBeMember(method, ["By_lim", "By_values"])} = "By_values"
    expand_value {mustBeNumeric(expand_value)} = 0.2;
end

ax = char(ax);

switch method
    case "By_lim"
        Limits = get(ax_frame, [ax 'lim']);
        Span = Limits(2) - Limits(1);
    case "By_values"
        [Span, Limits] = find_limits(ax_frame, ax);
end

if isempty(Span)
    return
end

Min = Limits(1);
Max = Limits(2);

Scale = get(ax_frame, [ax 'scale']);
if Scale == "log"
    newmin = Min / (expand_value*2+1);
    newmax = Max * (expand_value*2+1);
else
    newmin = Min - expand_value*Span;
    newmax = Max + expand_value*Span;
end

if newmin ~= newmax
    set(ax_frame, [ax 'lim'], [newmin newmax])
end

end