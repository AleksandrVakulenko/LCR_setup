
Fern.load("FRA_tools")

%%

[freq_list1] = freq_list_gen(10e3, 100e3, 13);
[freq_list2] = freq_list_gen(1.0, 8e3, 50);
[freq_list3] = freq_list_gen(0.2, 0.8, 4);
[freq_list4] = freq_list_gen(0.005, 0.1, 4);
freq_list = [freq_list1 freq_list2 freq_list3 freq_list4];



clc

[Time_pred_mean, Time_pred_min, Time_pred_max] = ...
    time_predictor(freq_list, "ultra_fast");

disp(['Time min = ' num2str(Time_pred_min, '%0.1f') ' s']);
disp(['Time nor = ' num2str(Time_pred_mean, '%0.1f') ' s']);
disp(['Time max = ' num2str(Time_pred_max, '%0.1f') ' s']);
disp(newline)



[Time_pred_mean, Time_pred_min, Time_pred_max] = ...
    time_predictor(freq_list, "common");

disp(['Time min = ' num2str(Time_pred_min, '%0.1f') ' s']);
disp(['Time nor = ' num2str(Time_pred_mean, '%0.1f') ' s']);
disp(['Time max = ' num2str(Time_pred_max, '%0.1f') ' s']);
disp(newline)



[Time_pred_mean, Time_pred_min, Time_pred_max] = ...
    time_predictor(freq_list, "fine");

disp(['Time min = ' num2str(Time_pred_min, '%0.1f') ' s']);
disp(['Time nor = ' num2str(Time_pred_mean, '%0.1f') ' s']);
disp(['Time max = ' num2str(Time_pred_max, '%0.1f') ' s']);
disp(newline)



[Time_pred_mean, Time_pred_min, Time_pred_max] = ...
    time_predictor(freq_list, "most_accurate");

disp(['Time min = ' num2str(Time_pred_min, '%0.1f') ' s']);
disp(['Time nor = ' num2str(Time_pred_mean, '%0.1f') ' s']);
disp(['Time max = ' num2str(Time_pred_max, '%0.1f') ' s']);
disp(newline)





