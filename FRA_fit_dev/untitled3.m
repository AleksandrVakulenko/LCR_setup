clc

filename = 'test_results/test_17_R.mat';

load(filename);

[F_arr, Perm] = sort(F_arr);
A_arr = A_arr(Perm);
P_arr = P_arr(Perm);

P_arr = phase_shift_correction(P_arr);
% P_arr = P_arr +  100;

range = F_arr > 1000000;
F_arr(range) = [];
A_arr(range) = [];
P_arr(range) = [];

F_arr_log = log10(F_arr);

% Mult_A = max(A_arr);
Mult_A = A_arr(1);
A_arr = A_arr/Mult_A;
P_arr = P_arr - P_arr(1);

Fig = FRA_plot(F_arr, 'I, A', 'Phase, °');
Fig.replace(F_arr, A_arr, P_arr);
%%

P_arr = P_arr-5;

X_arr = A_arr .* cosd(P_arr);
Y_arr = A_arr .* sind(P_arr);

% X_arr = X_arr - 0.8;
% X_arr = 2*X_arr;
% Y_arr = Y_arr - (-0.2);

A_arr = sqrt(X_arr.^2 + Y_arr.^2);
P_arr = atan2(Y_arr, X_arr);



%%
X_arr = X_arr - mean(X_arr);
Y_arr = Y_arr - mean(Y_arr);
plot(X_arr, Y_arr, '.-')
% axis equal
grid on
xline(0)
yline(0)

% ylim([-1.1 1.1])
% xlim([-1.1 1.1])



%%
clc

X_arr = X_arr-F_arr_log/20;
Y_arr = Y_arr-F_arr_log/20;

Diff = diff2d(X_arr, Y_arr);

Diff_span = max(Diff) - min(Diff);
Diff_lvl_step = 0.000*Diff_span;
Diff_lvl = Diff_lvl_step;

stop = false;
i = 1;
k = 1;
X_out = [];
Y_out = [];
X_out(k) = X_arr(i);
Y_out(k) = Y_arr(i);
for i = 1:numel(Diff)
    if Diff(i) > Diff_lvl
        k = k + 1
        X_out(k) = X_arr(i);
        Y_out(k) = Y_arr(i);
        Diff_lvl = Diff_lvl + Diff_lvl_step;
    end
end
k = k + 1;
X_out(k) = X_arr(end);
Y_out(k) = Y_arr(end);

X_arr = X_arr+F_arr_log/20;
Y_arr = Y_arr+F_arr_log/20;

% X_out = X_out - mean(X_out);
% Y_out = Y_out - mean(Y_out);
plot(X_out, Y_out, '.-')
grid on
xline(0)
yline(0)





function d = diff2d(X, Y)

dx = diff(X);
dy = diff(Y);
d = sqrt(dx.^2 + dy.^2);

end














