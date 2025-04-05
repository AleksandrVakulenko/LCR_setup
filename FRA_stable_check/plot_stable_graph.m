
function fig = plot_stable_graph(Data, fig)
arguments
    Data
    fig = []
end
if isempty(fig)
    fig = figure('Position', [440 240 690 745], 'Resize', 'on');
else
    figure(fig);
end

time = Data.time;
X = Data.x;
Y = Data.y;
Delta_X = Data.delta_x;
Delta_Y = Data.delta_y;
Delta = Data.delta;
Delta_limit = Data.Delta_limit;

subplot('Position', [0.093    0.568    0.85    0.40])
cla
hold on
box on
grid on
plot(time, X, '.-r', 'LineWidth', 1.5, 'MarkerSize', 10)
plot(time, Y, '.-b', 'LineWidth', 1.5, 'MarkerSize', 10)
Xlim = get(gca, 'xlim');

subplot('Position', [0.093    0.086    0.85    0.40])
cla
hold on
box on
grid on
plot(time, Delta_X, '--r', 'LineWidth', 1.5)
plot(time, Delta_Y, '--b', 'LineWidth', 1.5)
plot(time, Delta, '-k', 'LineWidth', 1.5)
yline(Delta_limit, '-k')

set(gca, 'yscale', 'log')
Ylim = get(gca, 'ylim');
Ylim(1) = Delta_limit*0.1;
set(gca, 'ylim', Ylim);
set(gca, 'xlim', Xlim);

end