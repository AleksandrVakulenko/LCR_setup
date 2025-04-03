
filename = 'test_03_R.mat';

load(['test_results\' filename])
P_arr(P_arr<0) = P_arr(P_arr<0)+360;
P_arr = P_arr-180;

figure('Position', [440 240 690 745]);

subplot('Position', [0.093    0.568    0.85    0.40])
cla
plot(F_arr, A_arr, '.-b');
FRA_plot_design(gca, F_arr, 'I, A')
        
subplot('Position', [0.093    0.086    0.85    0.40])
cla
plot(F_arr, P_arr, '.-b');
FRA_plot_design(gca, F_arr, 'Phase, deg')