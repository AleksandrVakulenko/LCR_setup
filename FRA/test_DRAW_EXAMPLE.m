

Freq_min = 0.5; % Hz
Freq_max = 1e6; % Hz
Freq_num = 20;
freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);


F_arr = freq_list;
A_arr = rand(size(F_arr));
P_arr = rand(size(F_arr));

figure('Position', [440 240 690 745]);



subplot('Position', [0.093    0.568    0.85    0.40])
cla
plot(F_arr, A_arr, '-b');
FRA_plot_design(gca, freq_list, 'I, A')


subplot('Position', [0.093    0.086    0.85    0.40])
cla
plot(F_arr, P_arr, '-b');
FRA_plot_design(gca, freq_list, 'Phase, deg')
























