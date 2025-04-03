function FRA_plot_design(ax, freq_list, Ylable)
arguments
    ax
    freq_list {mustBeNumeric(freq_list)}
    Ylable (1,1) string
end
x_lim_freq(ax, freq_list);
xlabel('f, Hz')
ylabel(Ylable)
set(ax, 'box', 'on')
set(ax, 'ygrid', 'on')
set(ax, 'xgrid', 'on')
set(ax, 'xscale', 'log')
set_x_ticks(ax)
end



function x_lim_freq(ax, freq_list)
Min = min(freq_list);
Max = max(freq_list);
set(ax, 'xlim', [Min*0.8 Max*1.2]);
end