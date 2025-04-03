
% filename = 'test_01_R.mat';
% filename = 'test_02_R.mat';
filename = 'test_03_R.mat';
% filename = 'test_04_C.mat';
% filename = 'test_05_C.mat';

load(['test_results\' filename])
P_arr(P_arr<0) = P_arr(P_arr<0)+360;
P_arr = P_arr-180;

Fig = FRA_plot(F_arr, 'I, A', 'Phase, °', 'POW');


Fig.replace(F_arr, A_arr, P_arr)
