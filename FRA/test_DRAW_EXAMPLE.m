


clc

Freq_min = 1e3; % Hz
Freq_max = 100e6; % Hz
Freq_num = 40;
freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);


F_arr = freq_list;
A_arr = rand(size(F_arr))*1.*freq_list + freq_list;
P_arr = rand(size(F_arr))*180;
A_arr(A_arr<=0) = 0.01;

Fig = FRA_plot(freq_list, 'I, A', 'Phase, °', 'SI');


Fig.replace(F_arr, A_arr, P_arr)




%%
clc

Freq_min = 1; % Hz
Freq_max = 10000; % Hz
Freq_num = 40;
freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);


F_arr = freq_list;
A_arr = rand(size(F_arr))*1.*freq_list + freq_list;
P_arr = rand(size(F_arr))*180;
A_arr(A_arr<=0) = 0.01;

Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');

for i = 1:numel(F_arr)
    Fig.replace(F_arr(1:i), A_arr(1:i), P_arr(1:i))
%     pause(0.1)
end



%%

filename = 'test_03_R.mat';
% filename = 'test_04_C.mat';

load(['test_results\' filename])
P_arr(P_arr<0) = P_arr(P_arr<0)+360;
P_arr = P_arr-180;



Fig = FRA_plot(F_arr, 'I, A', 'Phase, °');

for i = 1:numel(F_arr)
    Fig.replace(F_arr(1:i), A_arr(1:i), P_arr(1:i))
    pause(0.1)
end
















