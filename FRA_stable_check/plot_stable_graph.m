





function fig = plot_stable_graph(Data, fig, mode)
arguments
    Data
    fig = []
    mode {mustBeMember(mode, ["XY", "RPhi"])} = "XY"
end
if isempty(fig)
    fig = figure('Position', [485   134   690   904], 'Resize', 'on');
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

if mode == "RPhi"
R = sqrt(X.^2 + Y.^2);
Phi = atan2(X, Y)/pi*180;
    V1 = R;
    V2 = Phi;
else
    V1 = X;
    V2 = Y;
end

subplot('Position', [0.0930    0.750    0.850    0.215])
cla
hold on
box on
grid on
plot(time, V1, '.-b', 'LineWidth', 1.5, 'MarkerSize', 10)
Xlim = get(gca, 'xlim');

subplot('Position', [0.0930    0.493    0.850    0.215])
cla
hold on
box on
grid on
plot(time, V2, '.-r', 'LineWidth', 1.5, 'MarkerSize', 10)
Xlim = get(gca, 'xlim');

subplot('Position', [0.0930    0.1156    0.8500    0.3200])
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