% Date: 2025.04.02
%
% ----INFO----:
% Test for FRA measurement

% ----TODO----:
% 1) do first run
% 2) seve results func
% ------------

clc

R_test = 1100; % Ohm

Freq_min = 1; % Hz
Freq_max = 1000; % Hz
Freq_num = 20;
Voltage_gen = 1; % V
Delta_limit = 0.1/100; % 1
filename = "test_01_R.mat";

% DEV INIT
SR860 = SR860_dev(4);
Ammeter = K6517b_dev(27);

% MAIN
try
    SR860.set_advanced_filter("on");
    SR860.set_sync_filter('on');
    SR860.set_detector_phase(0);
    SR860.set_expand(1, "XYR");
    SR860.set_harm_num(1);
    SR860.set_sync_src("INT");
    SR860.set_voltage_input_range(1);
    SR860.set_filter_slope("6 dB/oct");
    SR860.configure_input("VOLT");
    SR860.set_gen_config(0.001, 1e3);
    SR860.set_sensitivity(1, "voltage"); % FIXME: need auto-mode
    
    Voltage_gen_rms = Voltage_gen/sqrt(2);
    Current_max = Voltage_gen/R_test;
    freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);
    freq_list = flip(freq_list);

    Ammeter.config("current");
    Sense = Ammeter.set_sensitivity(Current_max*1.2, "current");
    Ammeter.enable_feedback("enable");
    adev_utils.Wait(3);

    figure('Position', [440 240 690 745]);

    A_arr = [];
    P_arr = [];
    F_arr = [];
    Timer = tic;
    for i = 1:numel(freq_list)
        time = toc(Timer);

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
        adev_utils.Wait(Period*0.9);

        stable = false;
        [R_old, Phase_old] = SR860.data_get_R_and_Phase;
        while ~stable
            [Amp, Phase] = SR860.data_get_R_and_Phase;
            Delta_R = (Amp - R_old)/Amp;
            Delta_Phase = (Phase - Phase_old)/Phase;
            R_old = Amp;
            Phase_old = Phase;
            Delta = abs(Delta_R) + abs(Delta_Phase);
            if Delta < Delta_limit
                stable = true;
            end
            DISP_DELTA(Delta, Delta_limit, "%");
        end
        % -----------------------------------------------
        [Amp, Phase] = SR860.data_get_R_and_Phase;

        Amp = Amp*Sense*sqrt(2);

        A_arr = [A_arr Amp];
        P_arr = [P_arr Phase];
        F_arr = [F_arr freq];

        subplot('Position', [0.093    0.568    0.85    0.40])
        cla
        plot(F_arr, A_arr, '-b');
        FRA_plot_design(gca, freq_list, 'I, A')
                
        subplot('Position', [0.093    0.086    0.85    0.40])
        cla
        plot(F_arr, P_arr, '-b');
        FRA_plot_design(gca, freq_list, 'Phase, deg')

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
disp(['Time passed = ' num2str(time) ' s']);

Ammeter.enable_feedback("disable");
delete(SR860);
delete(Ammeter);

save(filename, "A_arr", "P_arr", "F_arr", "Sense")









