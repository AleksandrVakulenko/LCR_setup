
clc


[freq_list1, min_time1] = freq_list_gen(1, 100e3, 150);
[freq_list2, min_time2] = freq_list_gen(0.1, 0.8, 8);
[freq_list3, min_time3] = freq_list_gen(0.001, 0.05, 4);

freq_list = [freq_list1 freq_list2 freq_list3];
min_time = min_time1 + min_time2 + min_time3;


Time_prediction = time_predictor(freq_list);

disp([num2str(Time_prediction/60) ' min'])


hold on
x1 = 1:numel(freq_list1);
x2 = [1:numel(freq_list2)] + x1(end);
x3 = [1:numel(freq_list3)] + x2(end);
plot(x1, freq_list1, '.b')
plot(x2, freq_list2, '.g')
plot(x3, freq_list3, '.r')
set(gca, 'yscale', 'log')





