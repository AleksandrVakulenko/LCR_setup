function [Amp, Phase, G_volt, Amp_er, Phase_er, Num_of_meas] = ...
    Lock_in_measure(SR860, Voltage_gen, freq, Delta_limit, ...
    times_option, save_pack)

Lockin_Tc = 0.25; % FIXME

%---Lock_in SET------------------------
Voltage_gen_rms = Voltage_gen/sqrt(2);
SR860.set_gen_config(Voltage_gen_rms, freq);
G_volt = SR860.get_genVF()*sqrt(2);
% TODO: could Tc be small in case of sync adaptive filter???
SR860.set_time_constant(Lockin_Tc);
%-------------------------------------

%---TIMES-----------------------------
Period = 1/freq;
% FIXME: add dependencies requirement
Times_conf = get_time_config(Period, times_option);
[Wait_time, Stable_Time_interval, Stable_timeout, ...
    Max_meas_time, Averaging_time] = Times_calc(Times_conf);
%-------------------------------------

% Wait befor stable check
adev_utils.Wait(Wait_time, 'Wait one Wait_time');

Stable_checker = stable_check(SR860, Delta_limit, "ppm", ...
    save_pack, Stable_Time_interval, 10, Stable_timeout);

while ~Stable_checker.test
    % nothing to do here
end
% -----------------------------------------------

max_k = 500;
Amp_arr = zeros(1, max_k);
Phase_arr = zeros(1, max_k);

k = 0;
Local_timer = tic;
stop = false;
while ~stop
    Time = toc(Local_timer);
    k = k + 1;
    if Time > Averaging_time || k == max_k
        stop = true;
    end
   
    [Amp_arr(k), Phase_arr(k)] = SR860.data_get_R_and_Phase();
end

Amp_arr(k+1:end) = [];
Phase_arr(k+1:end) = [];
Amp = mean(Amp_arr);
Phase = mean(Phase_arr);

if k > 1
    Amp_er = 3*std(Amp_arr);
    Phase_er = 3*std(Phase_arr);
else
    Amp_er = NaN;
    Phase_er = NaN;
end

Num_of_meas = k;

end




