function [Full_time_mean, Full_time_min, Full_time_max] = ...
    time_predictor(freq_list, time_config)
arguments
freq_list
time_config string {mustBeMember(time_config, ...
        ["fine", "common", "most_accurate", "ultra_fast"])} = "common"
end
% FIXME: delete default value for time_config

Full_time_max = 0;
Full_time_min = 0;
for i = 1:numel(freq_list)
    Period = 1/freq_list(i);
    % FIXME: why common?
    % FIXME: add dependencies requirement
    Times_conf = get_time_config(Period, time_config);
    [Wait_time, Stable_Time_interval, Stable_timeout, ...
        Max_meas_time, Averaging_time] = Times_calc(Times_conf);

    Max_time = Times_conf.Max_meas_time_fraction_of_period * Period + ...
        Averaging_time;

    Min_time = Wait_time + ...
        Times_conf.Min_number_of_stable_intervals * Stable_Time_interval + ...
        Averaging_time;

    if Max_time < Min_time
        Max_time = Min_time;
    end

    Full_time_min = Full_time_min + Min_time;
    Full_time_max = Full_time_max + Max_time;
end
Full_time_mean = mean([Full_time_min Full_time_max]);
Full_time_mean = Full_time_mean * 0.82*1.06*1.15; %FIXME: magic constant
end