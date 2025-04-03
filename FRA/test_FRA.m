% Date: 2025.04.02
%
% ----INFO----:
% Test for FRA measurement

% ----TODO----:
% 1) find error in date receive
% 2) filter speed effect?
% 3) sample ping
% 4) auto-range
% ------------

clc

R_test = 1200; % Ohm

Freq_min = 1; % Hz
Freq_max = 1000; % Hz
Freq_num = 20;
Voltage_gen = 1; % V
Delta_limit = 50/1e6;
filename = "test_06_R.mat";
Read_mode = "old"; % "old" or "new"



% DEV INIT
SR860 = SR860_dev(4);
Ammeter = K6517b_dev(27);

% MAIN
try
    SR860_set_common_profile(SR860);
    SR860.set_filter_slope("24 dB/oct"); % FIXME: fast or slow?
    SR860.set_sensitivity(1, "voltage"); % FIXME: need auto-mode
    
    Current_max = Voltage_gen/R_test;
    %Current_max = 1e-7;

    Ammeter.config("current");
    Sense = Ammeter.set_sensitivity(Current_max*1.1, "current");
    Ammeter.enable_feedback("enable");

    [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, Freq_num);

    Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');
    
    Voltage_gen_rms = Voltage_gen/sqrt(2);
    Time_arr = [];
    A_arr = [];
    P_arr = [];
    F_arr = [];
    Timer = tic;
    for i = 1:numel(freq_list)
        freq = freq_list(i);
        SR860.set_gen_config(Voltage_gen_rms, freq);
        Period = 1/freq;
        if Period <= 0.02 % FIXME: how to choose tc?
            SR860.set_time_constant(10*Period);
        elseif Period <= 0.05
            SR860.set_time_constant(5*Period);
        else
            SR860.set_time_constant(1.5*Period);
        end

        % -----------------------------------------------
        adev_utils.Wait(Period*1, 'Wait one period');
        stable = false;
        [R_old, Phase_old] = data_get_R_and_Phase_wrapper(SR860, Read_mode);
        Stable_timeout = Period;
        Stable_start_time = toc(Timer);
        while ~stable
            [Amp, Phase] = data_get_R_and_Phase_wrapper(SR860, Read_mode);
            Delta_R = (Amp - R_old)/Amp;
            Delta_Phase = (Phase - Phase_old)/Phase;
            R_old = Amp;
            Phase_old = Phase;
            Delta = abs(Delta_R) + abs(Delta_Phase);
            if Delta < Delta_limit
                stable = true;
            end
            DISP_DELTA(Delta, Delta_limit, "ppm");
            if (toc(Timer) - Stable_start_time) > Stable_timeout
                stable = true;
            end
%             pause(0.05)
        end
        % -----------------------------------------------

        [Amp, Phase] = SR860.data_get_R_and_Phase;
        time = toc(Timer);

        Amp = Amp*Sense*sqrt(2);

        Time_arr = [Time_arr time];
        A_arr = [A_arr Amp];
        P_arr = [P_arr Phase];
        F_arr = [F_arr freq];

        Fig.replace(F_arr, A_arr, P_arr);

        drawnow
    end
% END MAIN
catch ERR
    Ammeter.enable_feedback("disable");
    SR860.set_gen_config(0.001, 1e3);
    delete(SR860);
    delete(Ammeter);
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

function [Amp, Phase] = data_get_R_and_Phase_wrapper(SR860, mode)
arguments
    SR860
    mode {mustBeMember(mode, ["old", "new"])}
end
    OK = false;
    while ~OK
        try
            [Amp, Phase] = SR860.data_get_R_and_Phase;
            OK = true;
        catch
            if mode == "new"
                try_to_read_error(SR860);
            else
                disp("CATCH ERROR !")
            end
        end
    end
end


function try_to_read_error(SR860)
    fprintf('\n\n>>>>>CATCH ERROR>>>>>\n\n');
    ESR_struct = SR860.get_ESR;
    disp(ESR_struct)
    fprintf('<<<<<END CATCH ERROR<<<<<\n\n\n');
%     pause(5)
end

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

