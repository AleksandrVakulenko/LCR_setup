function set_x_ticks(ax)
Xlim = get(ax, 'xlim');

% xticks([1, 10, 20, 50, 100, 200])
Min = Xlim(1);
Max = Xlim(2);

Ticks = gen_log_tick([Min Max]);
if numel(Ticks) > 12
    Ticks(2:2:end) = [];
end
Tick_label = get_ticks_label(Ticks);

set(ax, 'xtick', Ticks);
set(ax, 'xticklabel', Tick_label);
end