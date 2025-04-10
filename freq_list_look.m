
clc


[freq_list1, min_time1] = freq_list_gen(0.5, 10e3, 100);
[freq_list2, min_time2] = freq_list_gen(0.001, 0.4, 8);
freq_list = [freq_list1 freq_list2];
min_time = min_time1 + min_time2;


Time_prediction = time_predictor(freq_list)/60;

hold on
x1 = 1:numel(freq_list1);
x2 = [1:numel(freq_list2)] + x1(end);
plot(x1, freq_list1, '.b')
plot(x2, freq_list2, '.r')
set(gca, 'yscale', 'log')


function [Full_time_mean, Full_time_min, Full_time_max] = time_predictor(freq_list)
Full_time_max = 0;
Full_time_min = 0;
for i = 1:numel(freq_list)
    Period = 1/freq_list(i);
    Times_conf = get_time_conf_common(Period);
    [Wait_time, Stable_Time_interval, Stable_timeout] = Times_calc(Times_conf);

    Max_time = Times_conf.Max_meas_time_fraction_of_period * Period;

    Min_time = Wait_time + ...
        Times_conf.Min_number_of_stable_intervals * Stable_Time_interval;

    if Max_time < Min_time
        Max_time = Min_time;
    end

    Full_time_min = Full_time_min + Min_time;
    Full_time_max = Full_time_max + Max_time;
end
Full_time_mean = mean([Full_time_min Full_time_max]);
end


