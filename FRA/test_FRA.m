% Date: 2025.04.07
%
% ----INFO----:
% Test for FRA measurement

% ----TODO----:
% 1) sample ping
% 2) auto-range
% 3) Sample info struct
% 4) FRA settings struct save
% 5) plot style
% 6) FRA data type

% ------------


%%
file_num = 0;

%%
clc

R_test = 1200; % Ohm


Voltage_gen = 0.01; % V

Freq_min = 1; % Hz
Freq_max = 10000; % Hz
Freq_num = 30;
Freq_permutation = false;

Delta_limit = 100e-6;

save_files_flag = false;
save_stable_data = false;


if save_files_flag
    file_num = file_num + 1;
    filename = ['test_results\test_' num2str(file_num, '%02u') '_R.mat'];
end

% DEV INIT
SR860 = SR860_dev(4);
Ammeter = K6517b_dev(27);

% MAIN ------------------------------------------------------------------------
try
    SR860.RESET();
    SR860_set_common_profile(SR860);
    
    
    Current_max = Voltage_gen/R_test;

    Ammeter.config("current");
    Sense_V2C = Ammeter.set_sensitivity(Current_max*1.1, "current");
    Ammeter.enable_feedback("enable");

%     [freq_list1, min_time1] = freq_list_gen(0.5, 10e3, 50);
%     [freq_list2, min_time2] = freq_list_gen(0.1, 0.4, 8);
%     freq_list = [freq_list1 freq_list2];
%     min_time = min_time1 + min_time2;

    [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, Freq_num);

    if Freq_permutation
        freq_list = freq_list(randperm(length(freq_list)));
    end

    Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');
    
    find_best_sense(SR860, Voltage_gen);
    pause(1.5);
    
    Time_arr = [];
    A_arr = [];
    P_arr = [];
    F_arr = [];
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
        %
        [Amp, Phase] = Lock_in_measure(SR860, ...
            Voltage_gen, freq, Delta_limit, save_pack);
%
        time = toc(Timer);

        Amp = Amp*Sense_V2C*sqrt(2);

        Time_arr = [Time_arr time];
        A_arr = [A_arr Amp];
        P_arr = [P_arr Phase];
        F_arr = [F_arr freq];
        
        if Freq_permutation
            [F_arr, Perm] = sort(F_arr);
            A_arr = A_arr(Perm);
            P_arr = P_arr(Perm);
        end

        Fig.replace(F_arr, A_arr, P_arr);

        drawnow
    end
% END MAIN --------------------------------------------------------------------
catch ERR
    Ammeter.enable_feedback("disable");
    SR860.set_gen_config(0.001, 1e3);
    delete(SR860);
    delete(Ammeter);
    disp('Call Destructors');
    rethrow(ERR);
end 

disp("Finished without errors")
Time_passed = Time_arr(end);
disp(['Time passed = ' num2str(Time_passed) ' s']);
disp(['Minimum time = ' num2str(min_time) ' s']);
disp(['ratio: ' num2str(Time_passed/min_time, '%0.2f')]);


Ammeter.enable_feedback("disable");
delete(SR860);
delete(Ammeter);

if save_files_flag
    save(filename, "A_arr", "P_arr", "F_arr", "Time_arr", "Sense_V2C")
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
    %-------------------------------------
    Times_conf.Period = Period;
    Times_conf.Max_meas_time_fraction_of_period = 1.4; % [1]
    Times_conf.Wait_fraction_of_period = 0.8; % [1]
    Times_conf.Min_number_of_stable_intervals = 3; % [1]
    Times_conf.Wait_min = 0.15; % [s]
    Times_conf.Stable_interval_min = 0.5; % [s]
    %-------------------------------------
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



function SR860_set_common_profile(SR860)
    SR860.configure_input("VOLT");
    SR860.set_advanced_filter("on");
    SR860.set_sync_filter('on');
    SR860.set_expand(1, "XYR");
    SR860.set_sync_src("INT");
    SR860.set_harm_num(1);
    SR860.set_filter_slope("6 dB/oct"); % FIXME: fast or slow?
    SR860.set_voltage_input_range(1);
    SR860.set_detector_phase(180); % NOTE: inv for K6517b
    SR860.set_gen_config(100e-6, 1e3); % NOTE: off
end



