
clc

Freq_min = 0.00001; % Hz
Freq_max = 5000; % Hz
Freq_num = 500;
Freq_permutation = false;

Delta_limit = 100e-6;
Stable_init_num = 10;

Lockin_Tc = 0.25;

[freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, Freq_num);


Wait_time_array = [];
Stable_Time_array = [];
Stable_timeout_array = [];
for i = 1:numel(freq_list)
    freq = freq_list(i);
    disp(['freq = ' num2str(freq) ' Hz'])
    Period = 1/freq;
    time_const = find_best_time_constant(Lockin_Tc);

    %---TIMES-----------------------------
    Times_conf.Period = Period;
    Times_conf.Max_meas_time_fraction_of_period = 1.4; % [1]
    Times_conf.Wait_fraction_of_period = 0.8; % [1]
    Times_conf.Min_number_of_stable_intervals = 3; % [1]
    Times_conf.Wait_min = 0.1; % [s]
    Times_conf.Stable_interval_min = 0.2; % [s]
    %-------------------------------------
    [Wait_time, Stable_interval, Stable_timeout] = Times_calc(Times_conf);
    %-------------------------------------

    

    Wait_time_array = [Wait_time_array Wait_time];
    Stable_Time_array = [Stable_Time_array Stable_interval];
    Stable_timeout_array = [Stable_timeout_array Stable_timeout];
end


figure
hold on
P = [];
P(1) = plot(1./freq_list, 1./freq_list, '--k', 'DisplayName', 'Period');
P(2) = yline(Lockin_Tc, '-.', "DisplayName", 'Lock-in Tc');
P(3) = plot(1./freq_list, Stable_timeout_array, '-g', 'LineWidth', 1.5, "DisplayName", 'Timeout');
P(4) = plot(1./freq_list, Stable_Time_array, '-r', 'LineWidth', 1.5, 'DisplayName', 'Stable');
P(5) = plot(1./freq_list, Wait_time_array, '-b', 'LineWidth', 1.5, 'DisplayName', 'Wait');
P(6) = plot(1./freq_list, Wait_time_array+Stable_timeout_array, '--m', 'LineWidth', 1.5);
% P(6) = plot(1./freq_list, Stable_timeout_array./Stable_Time_array, '--m', 'LineWidth', 1.5);


set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
grid on
box on
set_axis_ticks(gca, "SI", "x");
set_axis_ticks(gca, "SI", "y");
legend(P, 'Location', 'northwest')







function [time_const, ind] = find_best_time_constant(time_const)
tc_array = [1e-6, 3e-6, 10e-6, 30e-6, 100e-6, 300e-6, 1e-3, 3e-3, 10e-3, ...
    30e-3, 100e-3, 300e-3, 1, 3, 10, 30, 100, 300, 1000, 3000, 10e3, 30e3];

Min_tc = tc_array(1);
Max_tc = tc_array(end);
if time_const < Min_tc
    time_const = Min_tc;
end
if time_const > Max_tc
    time_const = Max_tc
end

[~, ind] = min(abs(tc_array-time_const));
time_const = tc_array(ind);
ind = ind - 1;

end
