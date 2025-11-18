

clc

N = 50000;
Thickness = Thickness_rand(N) * 1e-6; % m
Diameter = Diameter_rand(N) * 1e-3; % m
Eps = Eps_rand(N);
freq = 10.^linspace(log10(0.001), log10(10e3), 10); % Hz
% freq = 10.^linspace(log10(80), log10(500e3), 10); % Hz
% freq = 10;
V = 1.0;


S = pi*(Diameter/2).^2; % m^2
Cap = 8.85e-12*Eps.*S./Thickness; % F
R = 1./(2*pi*Cap'*freq);
R = reshape(R, 1, numel(R));
I = V./R;


I = reshape(I, 1, numel(I));
I_log = log10(I);

%
clc

fig = figure('Visible', 'off');
H = histogram(I_log, 'Normalization', 'pdf');
Edges = H.BinEdges;
I_log2 = (Edges(1:end-1) + Edges(2:end))/2;
PDF = H.Values;
delete(fig)

Min = prctile(I_log, 0.5);
P10 = prctile(I_log, 5);
P90 = prctile(I_log, 95);
Max = prctile(I_log, 99.5);


figure('Position', [400  375  815  530])
I_log2 = 10.^I_log2;
plot(I_log2, PDF, 'Marker', 'none', 'LineWidth', 2.0)
% xline(10.^P10, '--b', 'LineWidth', 1)
% xline(10.^P90, '--b', 'LineWidth', 1)

xline(30e-3, '-r', 'LineWidth', 1)
xline(500e-6, '-r', 'LineWidth', 1)
xline(5e-6, '-r', 'LineWidth', 1)
xline(50e-9, '-r', 'LineWidth', 1)
xline(500e-12, '-r', 'LineWidth', 1)
xline(5e-12, '-r', 'LineWidth', 1)

xline(7e-12, '--k', 'LineWidth', 2)
xline(25e-15, '--k', 'LineWidth', 2)

xlim([1e-15 1])
xlabel('I, A')
ylabel('PDF')
grid on

Plotlib.log_scale("x")
% xlim([1e-15 1e-2])




%

% I_array = [1e-2, ...
%            1e-3, 1e-4, 1e-5, ...
%            1e-6, 1e-7, 1e-8, ...
%            1e-9, 1e-10, 1e-11, ...
%            1e-12, 1e-13];


V_array = [2, 1, 0.5, 0.05, 0.005, 500e-6, 50e-6];

R_array = [100, 1e3, 1e6, 100e6, 1e9];


hold on

for i = 1:numel(R_array)
    I_array = V_array/R_array(i);
    plot(I_array, (i+1)*ones(size(I_array))/300, '.-b', 'MarkerSize', 12)
end





%%



function R = rand_range(Min, Max, N)
Span = Max - Min;
R = rand(1, N) * Span + Min;
end


function Thickness = Thickness_rand(N)
x_step = 0.1;
x = 0:x_step:3000;

y = gaussmf(x, [400, 100]) + gaussmf(x, [1000, 40]);

Arg = (x-80)/20;
y = y .* exp(Arg)./(1 + exp(Arg));

range = x < 30;
x(range) = [];
y(range) = [];

Sum = trapz(x, y);
y = y/Sum;

CDF = cumsum(y)*x_step;
CDF(1) = 0;
CDF(end) = 1;

Uni_rand = rand(1, N);

Dist_rand = interp1(CDF, x, Uni_rand);
Thickness = Dist_rand;
% figure
% plot(x, CDF)
% histogram(Dist_rand)
end



function Diameter = Diameter_rand(N)
x_step = 0.01;
x = 0:x_step:15;

y = gaussmf(x, [5, 1]);

Arg = (x-0.4)/0.03;
y = y .* exp(Arg)./(1 + exp(Arg));

range = x < 0.1;
x(range) = [];
y(range) = [];

Sum = trapz(x, y);
y = y/Sum;

CDF = cumsum(y)*x_step;
CDF(1) = 0;
CDF(end) = 1;

Uni_rand = rand(1, N);

Dist_rand = interp1(CDF, x, Uni_rand);
Diameter = Dist_rand;
% figure
% plot(x, CDF)
% histogram(Dist_rand)
end


function Eps = Eps_rand(N)
x_step = 0.001;
x = 0:x_step:40;

y = gaussmf(x, [8, 5]) + 0.2*gaussmf(x, [15, 5]);

range = x < 1;
Arg = (x(range)-0.02)/0.005;
y(range) = y(range) .* exp(Arg)./(1 + exp(Arg));

Sum = trapz(x, y);
y = y/Sum;



CDF = cumsum(y)*x_step;
CDF(1) = 0;
CDF(end) = 1;

Uni_rand = rand(1, N);

Dist_rand = interp1(CDF, x, Uni_rand);

Eps = Dist_rand*1000;
% figure
% plot(x, CDF)
% histogram(Dist_rand)
end




