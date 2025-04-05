%% TETS stable_check

% TODO: place into SR860

clc

time = 0:0.05:10;
X = 0.01*exp(-((time-3)/1).^2)+0.01;
Y = -0.03*exp(-((time-5)/1).^2)+0.01;

figure
hold on
plot(time, X);
plot(time, Y);

SR860 = SR860_dummy(X, Y);

Stable_checker = stable_check(SR860, 50e-6, "none");

i = 0;
% stable = Stable_checker.test;
while ~Stable_checker.test
    i = i + 1;
    time_cut = time(1:i);
    X_cut = X(1:i);
    Y_cut = Y(1:i);
%     stable = Stable_checker.test;
    
    cla
    plot(time, X, '--r', 'LineWidth', 1);
    plot(time, Y, '--b', 'LineWidth', 1);
    plot(time_cut, X_cut, '-r', 'LineWidth', 2)
    plot(time_cut, Y_cut, '-b', 'LineWidth', 2)
    drawnow
end


%% TEST single_stable_check

time = 0:0.05:10;
X = 0.01*exp(-((time-3)/1).^2)+0.01;
Y = exp(-time/1)+0.01;

figure
hold on
plot(X, 'LineWidth', 2)
scs = single_stable_check(50/1e6);

i = 1;
stable = scs.test(X(i));
while ~stable
    i = i + 1;
    if i > numel(X)
        erorr('X is empty now')
    end
    stable = scs.test(X(i));
end

scs.draw







