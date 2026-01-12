
% TODO (FRA_data)
% 1) delete some data at some freqs
% 2) data sum and diff
% 3) .empty
% 4) add default linespec
% 5) add error data (for errorbar)

% TODO (FRA_plot)
% 1) add data with linespec


%% LOAD FILES
clc

% Folder_root = 'test_results_2025_04_23';
% Folder_root = 'test_results_2025_05_07';



% Folder_root = 'test_results_2025_12_02';

Folder_N = 1;

if Folder_N < 4
    Folder_root = 'test_results_2025_11_11';
else
    Folder_root = 'test_results_2025_11_25';
end

Folder = [Folder_root '\' 'Calibration_N_' num2str(Folder_N, "%02u")];

Freq = [];
R = [];
Phi = [];

clearvars Data_arr;
for loop_counter = 1:6
    loop_counter
    Filename = ['cfile_' num2str(Folder_N, "%02u") '_' ...
        num2str(loop_counter, "%02u") '_R.mat'];
%     load([char(Folder) '\' char(Filename)]);
    load([char(Folder) '\' char(Filename)], 'Data', 'Data_ref');

    [Data, Data_ref] = trim_data(Data, Data_ref);

    [Freq_in, R_in, Phi_in] = Data.RPhi();
%     Calibration_current = Voltage_gen/R_test;
%     R_in = R_in/Calibration_current;

    Freq(loop_counter, :) = Freq_in;
    R(loop_counter, :) = R_in;
    Phi(loop_counter, :) = Phi_in;

    Data_arr(loop_counter) = Data;
end
Freq = Freq(1,:);

R_mean = mean(R, 1);
Phi_mean = mean(Phi, 1);

Data_mean = FRA_data('R, [Ohm]', Freq, 'R', R_mean, 'Phi', Phi_mean);



Data_ref = interp_FRA_data(Data_ref, Data);
Correction_data = Data_ref/Data_mean;

corr_file_name = ['corr_Aster_dev_range_' num2str(Folder_N) '.mat'];

% save(corr_file_name, 'Correction_data');

Fig = FRA_plot;
Fig.replace_FRA_data([Data_arr.*Correction_data]);

%%


% R_corr = R_in*(R_ref/R_mean);
% Phi_corr = Phi_in + (Phi_ref - Phi_mean);

%%

clc
Fig = FRA_plot;
% Fig.replace_FRA_data([Data_arr Data_mean Data_ref]);
% Fig.replace_FRA_data([Data_ref]);
Fig.replace_FRA_data([Data_arr .* Correction_data]);


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




function [Data, Data_ref] = trim_data(Data, Data_ref)

L_freq = min(Data.freq);

if min(Data_ref.freq) > L_freq
    Data_ref.freq = [L_freq Data_ref.freq];
    Data_ref.X = [mean(Data_ref.X(1:3)) Data_ref.X];
    Data_ref.Y = [mean(Data_ref.Y(1:3)) Data_ref.Y];
end

[~, R, Phi] = Data.RPhi;
ind = find(abs(Phi) < 5);
ind = ind(end);
Data.freq = Data.freq(1:ind);
Data.X = Data.X(1:ind);
Data.Y = Data.Y(1:ind);

Freq_limit = Data.freq(end);

ind = find(Data_ref.freq > Freq_limit);
ind = ind(1);

Data_ref.freq = Data_ref.freq(1:ind);
Data_ref.X = Data_ref.X(1:ind);
Data_ref.Y = Data_ref.Y(1:ind);

end
