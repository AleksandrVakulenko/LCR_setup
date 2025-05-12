function FRA_plot_design(ax, freq_list, Ylable, Tick_style)
arguments
    ax
    freq_list {mustBeNumeric(freq_list)}
    Ylable (1,1) string
    Tick_style {mustBeMember(Tick_style, ["SI", "POW", "auto"])} = "auto"
end

xlabel('f, Hz')
set(ax, 'xgrid', 'on')
set(ax, 'xscale', 'log')
x_lim_freq(ax, freq_list);
expand_axis(ax, "x", "By_lim");
set_axis_ticks(ax, Tick_style, "x");

ylabel(Ylable)
set(ax, 'box', 'on')
set(ax, 'ygrid', 'on')
[need_y_log, Limits] = check_y_values(ax);
if need_y_log
    set(ax, 'ylim', Limits);
    set(ax, 'yscale', 'log')
    expand_axis(ax, "y");
    set_axis_ticks(ax, Tick_style, "y");
else
    expand_axis(ax, "y");
end

end



function x_lim_freq(ax, freq_list)
Min = min(freq_list);
Max = max(freq_list);
set(ax, 'xlim', [Min*1 Max*1]);
end



function [need_log, Limits] = check_y_values(ax_frame)

[Span, Limits] = find_limits(ax_frame, 'y');

if isempty(Span)
    need_log = false;
    Limits = [0 1];
    return;
end
Min = Limits(1);
Max = Limits(2);

if (Min == Max) || (Min < 0)
    need_log = false;
else
    Scale = log10(Max/Min);
    if Scale > 2
        need_log = true;
    else
        need_log = false;
    end
end
end





