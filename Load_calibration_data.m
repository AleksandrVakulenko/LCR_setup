
%% LOAD FILES
clc

Folder_root = 'test_results_2025_04_23';
% Folder_root = 'test_results_2025_05_07';
Folder_N = 7;

Folder = [Folder_root '\' 'Calibration_N_' num2str(Folder_N, "%02u")];

Freq = [];
R = [];
Phi = [];

for loop_counter = 1:3
    loop_counter
    Filename = ['cfile_' num2str(Folder_N, "%02u") '_' ...
        num2str(loop_counter, "%02u") '_R.mat'];
    load([char(Folder) '\' char(Filename)]);

    [Freq_in, R_in, Phi_in] = Data.RPhi;
    Calibration_current = Voltage_gen/R_test;
    R_in = R_in/Calibration_current;

    Freq(loop_counter, :) = Freq_in;
    R(loop_counter, :) = R_in;
    Phi(loop_counter, :) = Phi_in;

end
Freq = Freq(1,:);

clearvars -except Freq Freq_log R Phi Folder Data Delta_limit experimental_setup R_test ...
    Sense_Level Sense_V2C Time_arr Voltage_gen Sense_Level Calibration_data_struct
%% PLOT DATA

Freq_log = log10(Freq);

figure('position', [535 135 670 800])
subplot(2, 1, 1)
hold on
for loop_counter = 1:size(R, 1)
    plot(Freq, R(loop_counter, :), '-r')
end
xlabel('log_1_0(f)');
ylabel('R');
grid on

subplot(2, 1, 2)
hold on
for loop_counter = 1:size(R, 1)
    plot(Freq, Phi(loop_counter, :), '-r')
end
xlabel('log_1_0(f)');
ylabel('Phi');
grid on


R_mean = mean(R, 1);
Phi_mean = mean(Phi, 1);
R_errors = 3*std(R, 1);
Phi_errors = 3*std(Phi, 1);

subplot(2, 1, 1)
errorbar(Freq, R_mean, R_errors, '-b')
set(gca, 'xscale','log')

subplot(2, 1, 2)
errorbar(Freq, Phi_mean, Phi_errors, '-b')
set(gca, 'xscale','log')

%% CREATE STRUCT

% FIXME: add errors!!!
Data_for_corr = FRA_data('-', Freq, 'R', R_mean, 'Phi', Phi_mean);

Calibration_data_struct.data = Data_for_corr;
Calibration_data_struct.dev_type = experimental_setup.I2V_converter.class;
Calibration_data_struct.range = Sense_Level;
Calibration_data_struct.sense_V2C = Sense_V2C;
Calibration_data_struct.voltage = Voltage_gen;
Calibration_data_struct.resistance = R_test;



%% USE

Data_for_corr = Calibration_data_struct.data;
Data_new = Data/Data_for_corr;


Fig = FRA_plot();

[F, R, P] = Data_new.RPhi();
R = Voltage_gen./R;
% P = P*pi/180;
Data_new = FRA_data('Ohm', F, 'R', R, 'Phi', P);

Fig.replace_FRA_data(Data_new)








