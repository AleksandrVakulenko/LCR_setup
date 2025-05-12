
%% Fit and plot

% [Freq, R, Phi] = Data.RPhi;
F_arr = Freq_part;%Freq;
A_arr = R_mean_part;%mean(R, 1);
P_arr = Phi_mean_part;%mean(Phi, 1);

F_arr_log = log10(F_arr);
[~, yData_Phi] = prepareCurveData(F_arr_log, P_arr );
[xData, yData_R] = prepareCurveData(F_arr_log, A_arr);

ft = fittype('smoothingspline');
opts = fitoptions('Method', 'SmoothingSpline');
opts.Normalize = 'on';
opts.SmoothingParam = 0.999;

[fitresult_Phi] = fit(xData, yData_Phi, ft, opts);
[fitresult_R] = fit(xData, yData_R, ft, opts);

F_model = linspace(log10(min(F_arr)), log10(max(F_arr)), 100);
% F_model = linspace(log10(0.001), log10(1e6), 100);
Phi_model = feval(fitresult_Phi, F_model);
R_model = feval(fitresult_R, F_model);



figure( 'Name', 'untitled fit 1' );

subplot(2, 1, 1)
hold on
plot(xData, yData_R, '.');
plot(F_model, R_model, '-');
xlabel('F');
ylabel('R');
grid on

subplot(2, 1, 2)
hold on
plot(xData, yData_Phi, '.');
plot(F_model, Phi_model, '-');
xlabel('F');
ylabel('Phi');
grid on



%% Residuals

clc

F_model = F_arr_log;
Phi_model = feval(fitresult_Phi, F_model);
R_model = feval(fitresult_R, F_model);

figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, 'x');

subplot(2, 1, 1)
hold on
plot(F_model, yData_R-R_model, '-');
% plot(F_model, R_errors, '-r')
% plot(F_model, -R_errors, '-r')
xlabel('F');
ylabel('R');
grid on

subplot(2, 1, 2)
hold on
plot(F_model, yData_Phi-Phi_model, '-');
xlabel('F');
ylabel('Phi');
grid on






