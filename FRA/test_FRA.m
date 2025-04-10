% Date: 2025.04.10
%
% ----INFO----:
% Test for FRA measurement

% ----TODO----:
% 1) sample ping (in progress)
% 2) auto-range (in progress)
% 3) time predictor (ready V1)

% 4) Replace correction by interp1
% 5) FRA settings struct
% 6) Sample info struct
% 7) 

% ------------


%%
file_num = 5;

%%
clc

R_test = 1200; % Ohm

Voltage_gen = 0.5; % V

Freq_min = 0.1; % Hz
Freq_max = 2e3; % Hz
Freq_num = 30;
Freq_permutation = false;

Ammeter_type = get_ammeter_variants("DLPCA200");

Plot_corr_version = false;

Delta_limit = 50e-6;
save_files_flag = true;
save_stable_data = false;

% -----------FREQ LIST GEN----------------------------------
% [freq_list1, min_time1] = freq_list_gen(0.5, 10e3, 50);
% [freq_list2, min_time2] = freq_list_gen(0.1, 0.4, 8);
% freq_list = [freq_list1 freq_list2];
% min_time = min_time1 + min_time2;

[freq_list1, min_time1] = freq_list_gen(1, 100e3, 150);
[freq_list2, min_time2] = freq_list_gen(0.1, 0.8, 8);
[freq_list3, min_time3] = freq_list_gen(0.001, 0.05, 4);
freq_list = [freq_list1 freq_list2 freq_list3];
min_time = min_time1 + min_time2 + min_time3;

% [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, ...
%     Freq_num, Freq_permutation);
% ----------------------------------------------------------

if save_files_flag
    file_num = file_num + 1;
    filename = ['test_results\test_' num2str(file_num, '%02u') '_R.mat'];
end

% DEV INIT
SR860 = SR860_dev(4);
if Ammeter_type == "K6517b"
    Ammeter = K6517b_dev(27);
end

% MAIN ------------------------------------------------------------------------
Main_error = [];
try
    SR860_set_common_profile(SR860, "non_inv");

    Current_max = Voltage_gen/R_test;

    if Ammeter_type == "K6517b"
        Ammeter.config("current");
        Sense_V2C = Ammeter.set_sensitivity(Current_max*1.1, "current");
        Ammeter.enable_feedback("enable");
    elseif Ammeter_type == "DLPCA200"
        Sense_V2C = 1/1e3; % FIXME
    else
        error('Wrong type of ammeter')
    end

    Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');

    find_best_sense(SR860, Voltage_gen);


    Time_arr = zeros(size(freq_list));
    Data = FRA_data('I, [A]');
    Timer = tic;
    for i = 1:numel(freq_list)
        freq = freq_list(i);
        disp(' ')
        disp(['freq = ' num2str(freq) ' Hz'])

        save_pack = struct('comment', "real run", 'freq_list', freq_list, ...
            'freq', freq, 'i', i);
        if ~save_stable_data
            save_pack = [];
        end

        [Amp, Phase] = Lock_in_measure(SR860, ...
            Voltage_gen, freq, Delta_limit, save_pack);

        Amp = Amp*Sense_V2C*sqrt(2);
%         Amp = Voltage_gen./Amp;
        time = toc(Timer);

        Time_arr(i) = time;
        Data.add(freq, "R", Amp, "Phi", Phase);

        Data_corr = Data.correction();
        if Plot_corr_version
            Fig.replace_FRA_data(Data_corr);
        else
            Fig.replace_FRA_data(Data);
        end

    end
% END MAIN --------------------------------------------------------------------
catch Main_error
    
end

SR860.set_gen_config(0.001, 1e3);
delete(SR860);

if Ammeter_type == "K6517b"
    Ammeter.enable_feedback("disable");
    delete(Ammeter);
elseif Ammeter_type == "DLPCA200"
    % nothing to do
end

if isempty(Main_error)
    disp("Finished without errors")
    Time_passed = Time_arr(end);
    [Time_pred_mean ,Time_pred_min, Time_pred_max] = time_predictor(freq_list);
    disp(['Minimum time = ' num2str(min_time) ' s']);
    disp(['Time prediction = ' num2str(Time_pred_mean) ' s']);
    disp(['Time passed = ' num2str(Time_passed) ' s']);
    disp(['ratio: ' num2str(Time_passed/Time_pred_mean, '%0.2f')]);

    if save_files_flag
        [F_arr, A_arr, P_arr] = Data.RPhi;
        save(filename, "A_arr", "P_arr", "F_arr", "Time_arr", "Sense_V2C")
    end

else
    rethrow(Main_error);
end






%-------------------------------------------------------------------------------

function find_best_sense(SR860, Voltage_gen)
Delta_limit = 200e-6;

freq = 10;

SR860.set_sensitivity(1, "voltage"); % FIXME: need auto-mode
[Amp, ~] = Lock_in_measure(SR860, ...
    Voltage_gen, freq, Delta_limit, []);

Amp = Amp*1.2;

SR860.set_sensitivity(Amp, "voltage");

%     disp(['Amp = ' num2str(Amp) ' V'])
end


function [Amp, Phase] = Lock_in_measure(SR860, Voltage_gen, freq, ...
    Delta_limit, save_pack)

Lockin_Tc = 0.25; % FIXME

%---Lock_in SET------------------------
Voltage_gen_rms = Voltage_gen/sqrt(2);
SR860.set_gen_config(Voltage_gen_rms, freq);
% TODO: could Tc be small in case of sync adaptive filter???
SR860.set_time_constant(Lockin_Tc);
%-------------------------------------

%---TIMES-----------------------------
Period = 1/freq;
Times_conf = get_time_conf_common(Period);
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


function SR860_set_common_profile(SR860, phase_inv)
arguments
    SR860 SR860_dev
    phase_inv {mustBeMember(phase_inv, ["inv", "non_inv"])} = "non_inv"
end

if phase_inv == "inv"
    phase_shift = 180; % K6517b
else
    phase_shift = 0; % DLPCA-200
end

SR860.RESET();
SR860.configure_input("VOLT");
SR860.set_advanced_filter("on");
SR860.set_sync_filter('on');
SR860.set_expand(1, "XYR");
SR860.set_sync_src("INT");
SR860.set_harm_num(1);
SR860.set_filter_slope("6 dB/oct"); % FIXME: fast or slow?
SR860.set_voltage_input_range(1);
SR860.set_detector_phase(phase_shift);
SR860.set_gen_config(100e-6, 1e3); % NOTE: gen off
end



