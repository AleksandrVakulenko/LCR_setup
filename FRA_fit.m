% TODO: 
% 1) make FRA model object for correction

% https://www.electronics-tutorials.ws/filter/second-order-filters.html

clc

filename = 'test_results5/test_11_R.mat';

load(filename);

[F_arr, Perm] = sort(F_arr);
A_arr = A_arr(Perm);
P_arr = P_arr(Perm);

P_arr = phase_shift_correction(P_arr);
% P_arr = P_arr +  100;

range = F_arr > 200;
F_arr(range) = [];
A_arr(range) = [];
P_arr(range) = [];

Mult_A = max(A_arr);
A_arr = A_arr/Mult_A;

Fig = FRA_plot(F_arr, 'I, A', 'Phase, °');
Fig.replace(F_arr, A_arr, P_arr);


%% FIT FRA
clc

BS = @(f) (1i*2*pi*f);
Bode_cplx = @(num, den, f) (num(1) + num(2)*BS(f) + num(3)*BS(f).^2)./...
    (den(1) + den(2)*BS(f) + den(3)*BS(f).^2);
Bode_real = @(num, den, f) real(Bode_cplx(num, den, f));
Bode_imag = @(num, den, f) imag(Bode_cplx(num, den, f));
Bode_abs = @(num, den, f) abs(Bode_cplx(num, den, f));
Bode_phi = @(num, den, f) angle(Bode_cplx(num, den, f))*180/pi;


[vout] = fit_fra_tf(F_arr, A_arr, P_arr);

A_model = Bode_abs(vout(1:3), vout(4:6), F_arr);
Phi_model = Bode_phi(vout(1:3), vout(4:6), F_arr);
Phi_model = phase_shift_correction(Phi_model);


figure('Position', [412 157 737 775])
subplot(2, 1, 1)
hold on
plot(F_arr, A_arr, '-r', 'LineWidth', 2)
plot(F_arr, A_model, '-k', 'LineWidth', 1)
% plot(F_arr, A_arr-A_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')

subplot(2, 1, 2)
hold on
plot(F_arr, P_arr, '-r', 'LineWidth', 2)
plot(F_arr, Phi_model, '-k', 'LineWidth', 1)
% plot(F_arr, P_arr-Phi_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')

figure('Position', [412 157 737 775])
subplot(2, 1, 1)
hold on
plot(F_arr, A_arr-A_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')

subplot(2, 1, 2)
hold on
plot(F_arr, P_arr-Phi_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')

%%


F_model = 10.^linspace(log10(0.1), log10(10e3), 1000);

A_model = Bode_abs(vout(1:3), vout(4:6), F_arr);
Phi_model = Bode_phi(vout(1:3), vout(4:6), F_arr);
Phi_model = phase_shift_correction(Phi_model);

figure('Position', [412 157 737 775])
subplot(2, 1, 1)
hold on
% plot(F_arr, A_arr, '-r', 'LineWidth', 2)
% plot(F_model, A_model, '-k', 'LineWidth', 1)
plot(F_arr, A_arr-A_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')

subplot(2, 1, 2)
hold on
% plot(F_arr, P_arr, '-r', 'LineWidth', 2)
% plot(F_model, Phi_model, '-k', 'LineWidth', 1)
plot(F_arr, P_arr-Phi_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')
% set(gca, 'xscale', 'log')

%% NEW NEW NEW CORRECTION with FRA_data class



Data_exp = FRA_data('V', F_arr, 'R', A_arr, 'Phi', P_arr);
Data_diff = Data_exp.correction();
[F_model, A_corr, Phi_corr] = Data_diff.RPhi;

figure('Position', [412 157 737 775])
subplot(2, 1, 1)
hold on
% plot(F_arr, A_arr, '-r', 'LineWidth', 2)
% plot(F_model, A_model, '-k', 'LineWidth', 1)
% plot(F_arr, A_arr-A_model, '-r', 'LineWidth', 1)
plot(F_arr, A_corr, '--g', 'LineWidth', 1)
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')
xlim([0.01 100])

subplot(2, 1, 2)
hold on
% plot(F_arr, P_arr, '-r', 'LineWidth', 2)
% plot(F_model, Phi_model, '-k', 'LineWidth', 1)
% plot(F_arr, P_arr-Phi_model, '-r', 'LineWidth', 1)
plot(F_arr, Phi_corr, '--g', 'LineWidth', 1)
set(gca, 'xscale', 'log')
xlim([0.01 100])
% set(gca, 'xscale', 'log')


%%




P_arr = phase_shift_correction(P_arr);

figure
hold on
plot(F_arr, P_arr, 'x-b', 'LineWidth', 2)
% plot(F_arr(1:end-1), D_P_Arr, 'x-b', 'LineWidth', 2)

set(gca, 'xscale', 'log')







function P_arr = phase_shift_correction(P_arr)
    D_P_Arr = diff(P_arr);
    range_p = D_P_Arr > 180;
    range_n = D_P_Arr < -180;
    
    range_p = [false range_p];
    range_n = [false range_n];
    
    Phase_shift_array = zeros(size(P_arr));
    Phase_shift = 0;
    for i = 1:numel(range_p)
    if range_p(i)
        Phase_shift = Phase_shift - 360;
    end
    if range_n(i)
        Phase_shift = Phase_shift + 360;
    end
    Phase_shift_array(i) = Phase_shift;
    end
    
    P_arr = P_arr + Phase_shift_array;
end



function [vout] = fit_fra_tf(F_arr, A_arr, P_arr)

BS = @(f) (1i*2*pi*f);
Bode_cplx = @(num, den, f) (num(1) + num(2)*BS(f) + num(3)*BS(f).^2)./...
    (den(1) + den(2)*BS(f) + den(3)*BS(f).^2);
Bode_real = @(num, den, f) real(Bode_cplx(num, den, f));
Bode_imag = @(num, den, f) imag(Bode_cplx(num, den, f));
Bode_abs = @(num, den, f) abs(Bode_cplx(num, den, f));
Bode_phi = @(num, den, f) angle(Bode_cplx(num, den, f))*180/pi;

X_arr = A_arr .* cosd(P_arr);
Y_arr = A_arr .* sind(P_arr);

model_1 = @(v) [(Bode_real(v(1:3), v(4:6), F_arr) - X_arr),...
                (Bode_imag(v(1:3), v(4:6), F_arr) - Y_arr)];     
model_2 = @(v) [(Bode_abs(v(1:3), v(4:6), F_arr) - A_arr),...
                (Bode_phi(v(1:3), v(4:6), F_arr) - P_arr)];    

  
Lower = [    0    0    0      0    0    0];
Start = [    1    0    0      1    1    0];
Upper = [  inf  inf  inf    inf  inf  inf];


options = optimoptions('lsqnonlin', ...
    'FiniteDifferenceType','central', ...
    'MaxFunctionEvaluations', 8000, ...
    'FunctionTolerance', 1E-12, ...
    'Algorithm','trust-region-reflective', ... %levenberg-marquardt trust-region-reflective
    'MaxIterations', 5000, ...
    'StepTolerance', 1e-12, ...
    'PlotFcn', '', ... %optimplotresnorm optimplotstepsize OR ''  (for none)
    'Display', 'iter', ... %final off iter
    'FiniteDifferenceStepSize', 1e-12, ...
    'CheckGradients', true, ...
    'DiffMaxChange', 1e-12, ...
    'OptimalityTolerance', 1e-12);

% [vestimated,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(ModelFunction, Start, Lower, Upper, options);
[vout,~,~,~,~,~,~] = lsqnonlin(model_1, Start, Lower, Upper, options);
[vout,resnorm,residual,~,~,~,jacobian] = lsqnonlin(model_2, vout, Lower, Upper, options);

end









