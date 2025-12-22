
clc

clearvars Data_arr
for i = 1:5

corr_file_folder = 'FRA/Correction_data/';
corr_file_name = ['corr_Aster_dev_range_' num2str(i) '.mat'];


adr = fullfile([corr_file_folder '/' corr_file_name])

load(adr)

Data_arr(i) = Correction_data;

end


Fig = FRA_plot;
Fig.replace_FRA_data(Data*Data_arr(4));

%%

clc

Data_new = copy(Data);


Data_new.freq = Data_new.freq*1;


freq_in = Data_new.freq;

freq_min = min(freq_in)

%%
Data_out = apply_correction(Data_new, Correction_data);


Fig = FRA_plot;
% Fig.replace_FRA_data([Data_to_corr Data_out]);
% Fig.replace_FRA_data(Corr_data)
Fig.replace_FRA_data([Data_out Data_new])







function Data_out = interp_FRA_data(Data, Target)

Freq_tg = Target.freq;

Freq = Data.freq;
X = Data.X;
Y = Data.Y;

X_out = interp1(Freq, X, Freq_tg);
Y_out = interp1(Freq, Y, Freq_tg);

Data_out = FRA_data(Data.unit, Freq_tg, "X", X_out, "Y", Y_out);

end








function Data_out = apply_correction(Data, Correction_data)

Corr_data = copy(Correction_data);
Data_to_corr = copy(Data);
% Data_to_corr.freq = Data_to_corr.freq(9:10);
% Data_to_corr.X = Data_to_corr.X(9:10);
% Data_to_corr.Y = Data_to_corr.Y(9:10);

freq_min = min(Data_to_corr.freq);

if freq_min < min(Corr_data.freq)
    corr_freq = Corr_data.freq;
    corr_x = Corr_data.X;
    corr_y = Corr_data.Y;

    [corr_freq, ind] = sort(corr_freq);
    corr_x = corr_x(ind);
    corr_y = corr_y(ind);
    
    corr_freq = [freq_min corr_freq];
    corr_x = [corr_x(1) corr_x];
    corr_y = [corr_y(1) corr_y];

    Corr_data.freq = corr_freq;
    Corr_data.X = corr_x;
    Corr_data.Y = corr_y;
end

Correction_data_part = interp_FRA_data(Corr_data, Data_to_corr);

Data_out = Data_to_corr * Correction_data_part;

end


function Data_out = interp_FRA_data(Data_in, Data_target)

[Freq_tg, ~, ~] = Data_target.RPhi();
[Freq_in, R_in, Phi_in] = Data_in.RPhi();

R_new = interp1(Freq_in, R_in, Freq_tg);
Phi_new = interp1(Freq_in, Phi_in, Freq_tg);

Data_out = FRA_data(Data_in.unit, Freq_tg, "R", R_new, "Phi", Phi_new);

end








