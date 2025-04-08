% https://www.electronics-tutorials.ws/filter/second-order-filters.html
% A = 0.00074902, fc = 1629.35 Hz, d = 1.48
% A = 0.00074972, fc = 1618.60 Hz, d = 1.46
% A = 0.00074812, fc = 1617.29 Hz, d = 1.46
clc

filename = 'test_results/test_08_R.mat';

load(filename);

[F_arr, Perm] = sort(F_arr);
A_arr = A_arr(Perm);
P_arr = P_arr(Perm);

P_arr = phase_shift_correction(P_arr);
% P_arr = P_arr +  100;

Fig = FRA_plot(F_arr, 'I, A', 'Phase, °');
Fig.replace(F_arr, A_arr, P_arr);


%% FIT FRA
clc

% % SINGLE POLE
% Bode_cplx = @(A, fc, x) fc*A./(fc+1i*2*pi*x);
% Bode_real = @(A, fc, x) real(Bode_cplx(A, fc, x));
% Bode_imag = @(A, fc, x) imag(Bode_cplx(A, fc, x));
% Bode_abs = @(A, fc, x) abs(Bode_cplx(A, fc, x));
% Bode_phi = @(A, fc, x) angle(Bode_cplx(A, fc, x))*180/pi;

% % DOUBLE POLE
% BSS = @(f) (1i*2*pi*f);
% Bode_cplx = @(A, fc, d, f) A*(2*pi*fc)^2./(BSS(f).^2 + 2*d*(2*pi*fc)*BSS(f) + (2*pi*fc)^2);
% Bode_real = @(A, fc, d, f) real(Bode_cplx(A, fc, d, f));
% Bode_imag = @(A, fc, d, f) imag(Bode_cplx(A, fc, d, f));
% Bode_abs = @(A, fc, d, f) abs(Bode_cplx(A, fc, d, f));
% Bode_phi = @(A, fc, d, f) angle(Bode_cplx(A, fc, d, f))*180/pi;

% DOUBLE POLE (DIFFERENT fc)
BS = @(f) (1i*2*pi*f);
Bode_cplxSP = @(fc, f) (2*pi*fc)./(2*pi*fc+1i*2*pi*f);
Bode_cplx = @(A, fc1, fc2, fc3, f) A*(Bode_cplxSP(fc1, f) .* Bode_cplxSP(fc2, f) .* Bode_cplxSP(fc3, f));
Bode_real = @(A, fc1, fc2, fc3, f) real(Bode_cplx(A, fc1, fc2, fc3, f));
Bode_imag = @(A, fc1, fc2, fc3, f) imag(Bode_cplx(A, fc1, fc2, fc3, f));
Bode_abs = @(A, fc1, fc2, fc3, f) abs(Bode_cplx(A, fc1, fc2, fc3, f));
Bode_phi = @(A, fc1, fc2, fc3, f) angle(Bode_cplx(A, fc1, fc2, fc3, f))*180/pi;

Mult_A = max(A_arr);
A_arr = A_arr/Mult_A;

% model = @(v) [(Bode_abs(v(1), v(2), v(3), v(4), F_arr) - A_arr)./1,...
%               (Bode_phi(v(1), v(2), v(3), v(4), F_arr) - P_arr)./90 ];

X_arr = A_arr .* cosd(P_arr);
Y_arr = A_arr .* sind(P_arr);

model = @(v) [(Bode_real(v(1), v(2), v(3), v(4), F_arr) - X_arr)./1,...
              (Bode_imag(v(1), v(2), v(3), v(4), F_arr) - Y_arr)./90 ];      

Lower = [  0.9      0.5    0.5    0.5];
Start = [  1        1000   1000   1000];
Upper = [  1.1      100e3   100e3   100e3];


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
fc1 = vout(2);
fc2 = vout(3);
fc3 = vout(4);
% d = vout(3); % filter damping factor

A_model = Bode_abs(A, fc1, fc2, fc3, F_arr);
Phi_model = Bode_phi(A, fc1, fc2, fc3, F_arr);
Phi_model = phase_shift_correction(Phi_model);

% disp(['A = ' num2str(A), ', fc = ' num2str(fc, '%0.2f') ' Hz, d = ' num2str(d, '%0.2f')])
disp(['A = ' num2str(A), ', fc1 = ' num2str(fc1, '%0.2f') ' Hz, fc2 = ' num2str(fc2, '%0.2f') ' Hz'])

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












