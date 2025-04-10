
clc


[freq_list1, min_time1] = freq_list_gen(0.5, 10e3, 100);
[freq_list2, min_time2] = freq_list_gen(0.001, 0.4, 8);
freq_list = [freq_list1 freq_list2];
min_time = min_time1 + min_time2;


Time_prediction = time_predictor(freq_list)/60;

hold on
x1 = 1:numel(freq_list1);
x2 = [1:numel(freq_list2)] + x1(end);
plot(x1, freq_list1, '.b')
plot(x2, freq_list2, '.r')
set(gca, 'yscale', 'log')





