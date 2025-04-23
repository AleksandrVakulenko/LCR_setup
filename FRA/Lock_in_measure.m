function [Amp, Phase] = Lock_in_measure(SR860, Voltage_gen, freq, ...
    Delta_limit, times_option, save_pack)

Lockin_Tc = 0.25; % FIXME

%---Lock_in SET------------------------
Voltage_gen_rms = Voltage_gen/sqrt(2);
SR860.set_gen_config(Voltage_gen_rms, freq);
% TODO: could Tc be small in case of sync adaptive filter???
SR860.set_time_constant(Lockin_Tc);
%-------------------------------------

%---TIMES-----------------------------
Period = 1/freq;
if times_option == "common"
    Times_conf = get_time_conf_common(Period);
elseif times_option == "fine"
    Times_conf = get_time_conf_fine(Period);
else
    Times_conf = get_time_conf_common(Period);
end
[Wait_time, Stable_Time_interval, Stable_timeout] = Times_calc(Times_conf);
%-------------------------------------

% Wait befor stable check
adev_utils.Wait(Wait_time, 'Wait one Wait_time');

Stable_checker = stable_check(SR860, Delta_limit, "ppm", ...
    save_pack, Stable_Time_interval, 10, Stable_timeout);

while ~Stable_checker.test
    % nothing to do here
end
% -----------------------------------------------

[Amp, Phase] = SR860.data_get_R_and_Phase();
end