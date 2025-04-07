% Date: 2025.04.02
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

Voltage_gen = 1; % V

Freq_min = 1; % Hz
Freq_max = 1000; % Hz
Freq_num = 20;
Freq_permutation = false;

Delta_limit = 100e-6;
Stable_timeout = 10; % s
Stable_init_num = 10;

% Save filename gen
file_num = file_num + 1;
filename = ['test_results\test_' num2str(file_num, '%02u') '_R.mat'];

% DEV INIT
SR860 = SR860_dev(4);
Ammeter = K6517b_dev(27);

% MAIN ------------------------------------------------------------------------
try
    SR860_set_common_profile(SR860);
    SR860.set_filter_slope("6 dB/oct"); % FIXME: fast or slow?
    SR860.set_sensitivity(1, "voltage"); % FIXME: need auto-mode
    
    Current_max = Voltage_gen/R_test;

    Ammeter.config("current");
    Sense = Ammeter.set_sensitivity(Current_max*1.1, "current");
    Ammeter.enable_feedback("enable");

    [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, Freq_num);
    if Freq_permutation
        freq_list = freq_list(randperm(length(freq_list)));
    end

    Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');
    
    Voltage_gen_rms = Voltage_gen/sqrt(2);
    Time_arr = [];
    A_arr = [];
    P_arr = [];
    F_arr = [];
    Timer = tic;
    for i = 1:numel(freq_list)
        freq = freq_list(i);
        Period = 1/freq;
        SR860.set_gen_config(Voltage_gen_rms, freq);
        disp(' ')
        disp(['freq = ' num2str(freq) ' Hz'])

        % TODO: could Tc be small in case of sync adaptive filter???
        Time_const = SR860.set_time_constant(0.25);
%         Time_const = SR860.set_time_constant(Period*10);
        % -----------------------------------------------
        
        if Period <= 0.1 % FIXME: how to choose tc?
            Wait_time = 0.2;
        else
            Wait_time = 0.9*Period;
        end
                
        % Wait befor stable check
        adev_utils.Wait(Wait_time, 'Wait one Wait_time');

        % Stable check part
        save_pack = struct('comment', "real run", 'freq_list', freq_list, ... 
            'freq', freq, 'Wait_time', Wait_time, 'i', i);
        Stable_checker = stable_check(SR860, Delta_limit, "ppm", ...
            save_pack, Stable_init_num, Stable_timeout);
        while ~Stable_checker.test
            % wait
        end
        % -----------------------------------------------

        [Amp, Phase] = SR860.data_get_R_and_Phase();
        time = toc(Timer);

        Amp = Amp*Sense*sqrt(2);

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
disp(['Time passed = ' num2str(Time_arr(end)) ' s']);
disp(['Minimum time = ' num2str(min_time) ' s']);


Ammeter.enable_feedback("disable");
delete(SR860);
delete(Ammeter);

save(filename, "A_arr", "P_arr", "F_arr", "Time_arr", "Sense")




%-------------------------------------------------------------------------------

function [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, Freq_num)
    freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);
    freq_list = flip(freq_list);
    periods = 1./freq_list;
    min_time = sum(periods);
end

function SR860_set_common_profile(SR860)
    SR860.configure_input("VOLT");
    SR860.set_advanced_filter("on");
    SR860.set_sync_filter('on');
    SR860.set_expand(1, "XYR");
    SR860.set_sync_src("INT");
    SR860.set_harm_num(1);
    SR860.set_voltage_input_range(1);
    SR860.set_detector_phase(180); % NOTE: inv for K6517b
    SR860.set_gen_config(100e-6, 1e3); % NOTE: off
end



