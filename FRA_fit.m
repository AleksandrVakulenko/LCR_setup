% https://www.electronics-tutorials.ws/filter/second-order-filters.html
% A = 0.00074902, fc = 1629.35 Hz, d = 1.48
% A = 0.00074972, fc = 1618.60 Hz, d = 1.46
% A = 0.00074812, fc = 1617.29 Hz, d = 1.46
clc

filename = 'test_results/test_15_R.mat';

load(filename);

Fig = FRA_plot(F_arr, 'I, A', 'Phase, °');
Fig.replace(F_arr, A_arr, P_arr);


%% FIT FRA

% SINGLE POLE
% Bode_cplx = @(A, fc, x) fc*A./(fc+1i*2*pi*x);
% Bode_real = @(A, fc, x) real(Bode_cplx(A, fc, x));
% Bode_imag = @(A, fc, x) imag(Bode_cplx(A, fc, x));
% Bode_abs = @(A, fc, x) abs(Bode_cplx(A, fc, x));
% Bode_phi = @(A, fc, x) angle(Bode_cplx(A, fc, x))*180/pi;

% DOUBLE POLE
BSS = @(f) (1i*2*pi*f);
Bode_cplx = @(A, fc, d, f) A*(2*pi*fc)^2./(BSS(f).^2 + 2*d*(2*pi*fc)*BSS(f) + (2*pi*fc)^2);
Bode_real = @(A, fc, d, f) real(Bode_cplx(A, fc, d, f));
Bode_imag = @(A, fc, d, f) imag(Bode_cplx(A, fc, d, f));
Bode_abs = @(A, fc, d, f) abs(Bode_cplx(A, fc, d, f));
Bode_phi = @(A, fc, d, f) angle(Bode_cplx(A, fc, d, f))*180/pi;

% A_model = Bode_abs(1, 100, F_arr);
% Phi_model = Bode_phi(1, 100, F_arr);

Mult_A = max(A_arr);
A_arr = A_arr/Mult_A;

model = @(v) [(Bode_abs(v(1), v(2), v(3), F_arr) - A_arr)./1,...
              (Bode_phi(v(1), v(2), v(3), F_arr) - P_arr)./90 ];
          

Lower = [  0.7      0.5    0.5];
Start = [  1        1000    1 ];
Upper = [  1.3      2000   2];


options = optimoptions('lsqnonlin', ...
    'FiniteDifferenceType','central', ...
    'MaxFunctionEvaluations', 8000, ...
    'FunctionTolerance', 1E-15, ...
    'Algorithm','trust-region-reflective', ... %levenberg-marquardt trust-region-reflective
    'MaxIterations', 5000, ...
    'StepTolerance', 1e-17, ...
    'PlotFcn', '', ... %optimplotresnorm optimplotstepsize OR ''  (for none)
    'Display', 'iter', ... %final off iter
    'FiniteDifferenceStepSize', 1e-12, ...
    'CheckGradients', true, ...
    'DiffMaxChange', 1e-12, ...
    'OptimalityTolerance', 1e-12);

% [vestimated,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(ModelFunction, Start, Lower, Upper, options);
[vout,resnorm,residual,~,~,~,jacobian] = lsqnonlin(model, Start, Lower, Upper, options);

% vout(1)

A_arr = A_arr*Mult_A;
A = vout(1)*Mult_A;
fc = vout(2);
d = vout(3); % filter damping factor

A_model = Bode_abs(A, fc, d, F_arr);
Phi_model = Bode_phi(A, fc, d, F_arr);

disp(['A = ' num2str(A), ', fc = ' num2str(fc, '%0.2f') ' Hz, d = ' num2str(d, '%0.2f')])

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



%%


F_model = 10.^linspace(log10(0.1), log10(10e3), 1000);

A_model = Bode_abs(A, fc, d, F_model);
Phi_model = Bode_phi(A, fc, d, F_model);

figure('Position', [412 157 737 775])
subplot(2, 1, 1)
hold on
plot(F_arr, A_arr, '-r', 'LineWidth', 2)
plot(F_model, A_model, '-k', 'LineWidth', 1)
% plot(F_arr, A_arr-A_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

subplot(2, 1, 2)
hold on
plot(F_arr, P_arr, '-r', 'LineWidth', 2)
plot(F_model, Phi_model, '-k', 'LineWidth', 1)
% plot(F_arr, P_arr-Phi_model, '-r', 'LineWidth', 1)
set(gca, 'xscale', 'log')
% set(gca, 'xscale', 'log')


























