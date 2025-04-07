function [Wait_time, Stable_interval, Stable_timeout] = Times_calc(Times_conf)
Period = Times_conf.Period;
Max_meas_time_fop = Times_conf.Max_meas_time_fraction_of_period; % [1]
Wait_fop = Times_conf.Wait_fraction_of_period; % [1]
Min_number_of_stab_inters = Times_conf.Min_number_of_stable_intervals; % [1]
Wait_min = Times_conf.Wait_min; % [s]
Stable_interval_min = Times_conf.Stable_interval_min; % [s]


Max_meas_time = Period*Max_meas_time_fop;

if Period <= Wait_min
    Wait_time = Wait_min;
else
    Wait_time = Wait_fop*Period + ...
        Wait_min*(1-Wait_fop);
end

Last_meas_time = Max_meas_time - Wait_time;

Stable_interval = log10(Period)/3*5; % NOTE: magic constant

if Stable_interval < Stable_interval_min
    Stable_interval = Stable_interval_min;
end

Stable_timeout = Max_meas_time - Wait_time;
if Stable_timeout < 0
    Stable_timeout = Max_meas_time;
end

if Stable_timeout < Min_number_of_stab_inters * Stable_interval
    Stable_timeout = Min_number_of_stab_inters * Stable_interval;
end
end