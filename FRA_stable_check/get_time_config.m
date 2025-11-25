
function Times_conf = get_time_config(Period, mode)
arguments
    Period double
    mode string {mustBeMember(mode, ...
        ["fine", "common", "most_accurate", "ultra_fast"])} = "common"
end


switch mode
    case "ultra_fast"
        Times_conf = get_time_conf_ultra_fast(Period);
    case "common"
        Times_conf = get_time_conf_common(Period);
    case "fine"
        Times_conf = get_time_conf_fine(Period);
    case "most_accurate"
        Times_conf = get_time_conf_most_accurate(Period);
    otherwise
        error("impossible code execution")
end

end


function Times_conf = get_time_conf_ultra_fast(Period)
    Times_conf.Period = Period;
    Times_conf.Max_meas_time_fraction_of_period = 1.1; % [1]
    Times_conf.Wait_fraction_of_period = 0.2; % [1]
    Times_conf.Min_number_of_stable_intervals = 2; % [1]
    Times_conf.Wait_min = 0.05; % [s]
    Times_conf.Stable_interval_min = 0.15; % [s]
end


function Times_conf = get_time_conf_common(Period)
    Times_conf.Period = Period;
    Times_conf.Max_meas_time_fraction_of_period = 1.4; % [1]
    Times_conf.Wait_fraction_of_period = 0.8; % [1]
    Times_conf.Min_number_of_stable_intervals = 3; % [1]
    Times_conf.Wait_min = 0.15; % [s]
    Times_conf.Stable_interval_min = 0.5; % [s]
end


function Times_conf = get_time_conf_fine(Period)
    Times_conf.Period = Period;
    Times_conf.Max_meas_time_fraction_of_period = 1.5; % [1]
    Times_conf.Wait_fraction_of_period = 0.8; % [1]
    Times_conf.Min_number_of_stable_intervals = 5; % [1]
    Times_conf.Wait_min = 0.5; % [s]
    Times_conf.Stable_interval_min = 1.0; % [s]
end


function Times_conf = get_time_conf_most_accurate(Period)
    Times_conf.Period = Period;
    Times_conf.Max_meas_time_fraction_of_period = 2.0; % [1]
    Times_conf.Wait_fraction_of_period = 0.8; % [1]
    Times_conf.Min_number_of_stable_intervals = 5; % [1]
    Times_conf.Wait_min = 2.0; % [s]
    Times_conf.Stable_interval_min = 1.5; % [s]
end
