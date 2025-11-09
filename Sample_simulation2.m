


Res = [100 10e3 1e6 100e6 10e9 1e12];
freq_red = [500e3 300e3 30e3 300 1 0.05];
freq_green = [250e3 100e3 10e3 100 1 0.05];

Current = 5./Res;

hold on
plot(log10(Current), log10(freq_red), '-r', 'LineWidth', 3)
plot(log10(Current), log10(freq_green), '-g', 'LineWidth', 3)
% plot(log10(Current/100), log10(freq), '-r', 'LineWidth', 3)
% plot(freq, Res, '-r', 'LineWidth', 3)

% set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')

%%

Res = [100 10e3 1e6 100e6 10e9 1e12];
freq_red = [500e3 300e3 30e3 300 1 0.05];
freq_green = [250e3 100e3 10e3 100 1 0.05];
freq = freq_green;

Current_max = 5./Res;
Current_min = Current_max/256;
freq2 = [];
freq2(1:2:numel(freq)*2) = freq;
freq2(2:2:numel(freq)*2) = freq;
freq = freq2;
Current2 = [];
Current2(1:2:numel(Current_max)*2) = Current_max;
Current2(2:2:numel(Current_max)*2) = Current_min;
Current = Current2;

hold on
plot(log10(Current), log10(freq), '-r', 'LineWidth', 3)

%%

Current_list = linspace(-15, 0, 101);
Freq_list = 10.^linspace(log10(0.001), log10(500e3), 100);
i = 20;
Full_map = zeros(100, 100);

clc

for i = 1:numel(Freq_list)
    i
N = 50000;
Thickness = Thickness_rand(N) * 1e-6; % m
Diameter = Diameter_rand(N) * 1e-3; % m
Eps = Eps_rand(N);
freq = Freq_list(i); % Hz
% freq = 10.^linspace(log10(80), log10(500e3), 10); % Hz
% freq = 10;
V = 1.0;


S = pi*(Diameter/2).^2; % m^2
% Cap = 8.85e-12*Eps.*S./Thickness; % F
Cap = [1e-12, 10e-12, 30e-12, 100e-12, 1e-9, 2e-9, 5e-9, 10e-9, 20e-9];
R = 1./(2*pi*Cap'*freq);
R = reshape(R, 1, numel(R));
I = V./R;


I = reshape(I, 1, numel(I));
I_log = log10(I);

fig = figure('Visible', 'off');
H = histogram(I_log, Current_list, 'Normalization', 'pdf');
% H = histogram(I_log, 'Normalization', 'pdf');
Edges = H.BinEdges;
I_log2 = (Edges(1:end-1) + Edges(2:end))/2;
PDF = H.Values;
delete(fig)

Full_map(i, :) = PDF;
end

imagesc(Current_list, log10(Freq_list), Full_map)
set(gca,'YDir','normal')

%%
figure('Position', [400  375  815  530])
I_log2 = 10.^I_log2;
plot(I_log2, PDF, 'Marker', 'none', 'LineWidth', 2.0)




xlim([1e-15 1])
xlabel('I, A')
ylabel('PDF')
grid on
set(gca, 'xscale', 'log')
set_axis_ticks(gca, "auto", "x")
% set(gca, 'xscale', 'log')
% xlim([1e-15 1e-2])








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








