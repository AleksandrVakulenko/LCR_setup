% function [fitresult] = createFit(F_arr, P_arr)

F_arr_log = log10(F_arr);
[xData, yData_Phi] = prepareCurveData(F_arr_log, P_arr );
[xData, yData_R] = prepareCurveData(F_arr_log, A_arr);

ft = 'pchipinterp';


[fitresult_Phi] = fit( xData, yData_Phi, ft, 'Normalize', 'on' );
[fitresult_R] = fit( xData, yData_R, ft, 'Normalize', 'on' );

F_model = linspace(log10(min(F_arr)), log10(max(F_arr)), 100);
Phi_model = feval(fitresult_Phi, F_model);
R_model = feval(fitresult_R, F_model);

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, 'x');
hold on

plot(xData, yData_R, '.');
plot(F_model, R_model, '-');
% plot(xData, yData_Phi, '.');
% plot(F_model, Phi_model, '-');

xlabel( 'F', 'Interpreter', 'none' );
ylabel( 'Phi', 'Interpreter', 'none' );

grid on

% end
