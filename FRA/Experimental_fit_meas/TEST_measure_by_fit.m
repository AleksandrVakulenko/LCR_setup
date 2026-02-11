%% Fit_dev test

% load('100Hz_57474.mat')
load('1Hz_54634.mat')

Time_all = T_a;
Voltage_all = V;
Current_all = I;
freq = Freq;

clearvars T_a V I Freq

plot(Time_all, Current_all)

%%

clc

TD = Test_dev(Time_all, Voltage_all, -Current_all);

Ammeter = TD;


[Amp_out, Phase_out] = measure_by_fit(Ammeter, freq);

disp(['Amp = ' num2str(Amp_out, '%0.2f') 'Ohm // Phi = ' ...
    num2str(Phase_out, '%0.3f') ' deg'])

