

function time_predictor_disp(freq_list, Time_passed)
[Time_pred_mean, Time_pred_min, Time_pred_max] = time_predictor(freq_list);
disp(['Time prediction = ' num2str(Time_pred_mean) ' s']);
disp(['Time passed = ' num2str(Time_passed) ' s']);
disp(['ratio: ' num2str(Time_passed/Time_pred_mean, '%0.2f')]);
end

