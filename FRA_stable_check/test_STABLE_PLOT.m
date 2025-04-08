
clc

folder = '../FRA/Debug_stable_data/';
names_out = find_stable_data_files(folder);


%%
clc

fig = [];
for i = numel(names_out)-73
load(names_out(i).full_path);

N = Stable_Data.pack.i;
freq = Stable_Data.pack.freq;

fig = plot_stable_graph(Stable_Data, fig);
title([num2str(N) ' | ' num2str(freq) ' Hz'])
num2str(N)
end



%%
clc

fig = [];
i = 20;
load(names_out(i).full_path);

N = Stable_Data.pack.i;
freq = Stable_Data.pack.freq;

fig = plot_stable_graph(Stable_Data, fig, "XY");
title([num2str(N) ' | ' num2str(freq) ' Hz'])


%%
clc

i = 275;
load(names_out(i).full_path);

time = Stable_Data.time;
X = Stable_Data.x;
Y = Stable_Data.y;
N = Stable_Data.pack.i;
freq = Stable_Data.pack.freq;


Stable_init_num = 10;
Stable_timeout = 10; % s
Delta_limit = 100e-6;


SR860 = SR860_dummy(X, Y);

Stable_checker = stable_check(SR860, Delta_limit, "ppm", ...
    [], Stable_init_num, Stable_timeout);


figure('Position', [464   257   665   789])

i = 1;
% stable = Stable_checker.test;
while ~Stable_checker.test
    i = i + 1;
    if i > numel(time)
        break
    end
    time_cut = time(1:i);
    X_cut = X(1:i);
    Y_cut = Y(1:i);
%     stable = Stable_checker.test;
    
    subplot(2,1,1)
    hold on
    cla
    plot(time, X, '--r', 'LineWidth', 1);
    plot(time_cut, X_cut, '-r', 'LineWidth', 2)


    subplot(2,1,2)
    hold on
    cla
    plot(time, Y, '--b', 'LineWidth', 1);
    plot(time_cut, Y_cut, '-b', 'LineWidth', 2)
    title([num2str(N) ' | ' num2str(freq) ' Hz'])
    drawnow
end



