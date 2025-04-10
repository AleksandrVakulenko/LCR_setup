
function Times_conf = get_time_conf_common(Period)

Times_conf.Period = Period;
Times_conf.Max_meas_time_fraction_of_period = 1.4; % [1]
Times_conf.Wait_fraction_of_period = 0.8; % [1]
Times_conf.Min_number_of_stable_intervals = 3; % [1]
Times_conf.Wait_min = 0.15; % [s]
Times_conf.Stable_interval_min = 0.5; % [s]

end




