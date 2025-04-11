

clc

N = 50000;

H = rand_range(50, 5000, N) * 1e-6; % m
D = rand_range(0.5, 10, N) * 1e-3; % m
S = pi*(D/2).^2; % m^2
Eps = rand_range(1, 40000, N);

Cap = 8.85e-12*Eps.*S./H; % F


freq = 10.^linspace(log10(0.001), log10(1000), 10); % Hz

R = 1./(2*pi*Cap'*freq);

V = 1;

I = V./R;

I = reshape(I, 1, numel(I));

I_log = log10(I);

%%

histogram(I_log)
xline(log10(20e-3), '-r')
xline(log10(10e-3), '-r')
xline(log10(1e-6), '-r')
xline(log10(1e-9), '-r')









function R = rand_range(Min, Max, N)

Span = Max - Min;

R = rand(1, N) * Span + Min;

end


