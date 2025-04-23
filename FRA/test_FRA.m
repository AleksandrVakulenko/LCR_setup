% Date: 2025.04.10
%
% ----INFO----:
% Test for FRA measurement

% ----TODO----:
%  1) Add lock-in I-V converter
%  2) Test lock-in I-V converter
%  3) 
%  4) Freq list generator
%  5) sample ping (in progress)
%  6) auto-range (in progress)
%  7) Replace correction by interp1
%  8) Add more stable settings
%  9) FRA settings struct
% 10) Sample info struct
% 11) Add Harm measuring
% 12) time predictor auto-update

% ------------


%%
file_num = 5;

%%
clc

DLPCA200_COM_PORT = 4; % FIXME!!!!

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
% [freq_list1] = freq_list_gen(0.5, 10e3, 50);
% [freq_list2] = freq_list_gen(0.1, 0.4, 8);
% freq_list = [freq_list1 freq_list2];

[freq_list1] = freq_list_gen(1, 100e3, 150);
[freq_list2] = freq_list_gen(0.1, 0.8, 8);
[freq_list3] = freq_list_gen(0.001, 0.05, 4);
freq_list = [freq_list1 freq_list2 freq_list3];

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
    Ammeter.config("current");
    Ammeter.enable_feedback("enable");
elseif Ammeter_type == "DLPCA200"
    Ammeter = DLPCA200_dev(DLPCA200_COM_PORT);
end

% MAIN ------------------------------------------------------------------------
Main_error = [];
try
    SR860_set_common_profile(SR860, "non_inv");

    Current_max = Voltage_gen/R_test;

    Sense_V2C = Ammeter.set_current_sensitivity(Current_max*1.1);

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
            Voltage_gen, freq, Delta_limit, "common", save_pack);

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
    delete(Ammeter);
else
    error('unreachable code!!!')
end

if isempty(Main_error)
    disp("Finished without errors")
    Time_passed = Time_arr(end);
    [Time_pred_mean ,Time_pred_min, Time_pred_max] = time_predictor(freq_list);
%     disp(['Minimum time = ' num2str(min_time) ' s']);
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






