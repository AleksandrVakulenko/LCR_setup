% FIXME: add auto case

function set_axis_ticks(ax_frame, style, ax)
arguments
    ax_frame
    style {mustBeMember(style, ["SI", "POW", "auto"])} = "auto"
    ax {mustBeMember(ax, ["x", "y"])} = "y"
end
ax = char(ax);

Scale = get(ax_frame, [ax 'scale']);
if Scale ~= "log"
    return
end

Xlim = get(ax_frame, [ax 'lim']);
Min = Xlim(1);
Max = Xlim(2);

switch style
    case "SI"
        Grid = [1 2 5];
        Ticks = gen_log_tick([Min Max], Grid);
        if numel(Ticks) > 12
            Grid = [1 3];
            Ticks = gen_log_tick([Min Max], Grid);
            if numel(Ticks) > 12
                Grid = [1];
                Ticks = gen_log_tick([Min Max], Grid);
            end
        end

    case "POW"
        Grid = [1];
        Ticks = gen_log_tick([Min Max], Grid);

    case "auto"
        N = log10(Max/Min);
        if N < 4
            Grid = [1 2 5];
            Ticks = gen_log_tick([Min Max], Grid);
            style = "SI";
        else
            Grid = [1];
            Ticks = gen_log_tick([Min Max], Grid);
            style = "POW";
        end

end


switch style
    case "SI"
        Tick_label = get_ticks_label_SI(Ticks);
    case "POW"
        Tick_label = get_ticks_label_POW(Ticks);
end

set(ax_frame, [ax 'tick'], Ticks);
set(ax_frame, [ax 'ticklabel'], Tick_label);
end





