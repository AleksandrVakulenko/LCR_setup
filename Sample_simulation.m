

clc

N = 50000;
Thickness = Thickness_rand(N) * 1e-6; % m
Diameter = Diameter_rand(N) * 1e-3; % m
Eps = rand_range(1, 40000, N);
freq = 10.^linspace(log10(0.01), log10(1000), 10); % Hz
V = 1;


S = pi*(Diameter/2).^2; % m^2
Cap = 8.85e-12*Eps.*S./Thickness; % F
R = 1./(2*pi*Cap'*freq);
I = V./R;


I = reshape(I, 1, numel(I));
I_log = log10(I);

%%
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

range = (I_log2 < Min) | (I_log2 > Max);
I_log2(range) = [];
PDF(range) = [];

figure('Position', [400  375  815  530])
I_log2 = 10.^I_log2;
plot(I_log2, PDF, 'Marker', 'none', 'LineWidth', 2.0)
xline(10.^P10, '--b')
xline(10.^P90, '--b')
xlabel('I, A')
ylabel('PDF')
grid on
set(gca, 'xscale', 'log')
set_axis_ticks(gca, "SI", "x")
% set(gca, 'xscale', 'log')
% xlim([1e-15 1e-2])
% xline(log10(20e-3), '-r')
% xline(log10(10e-3), '-r')
% xline(log10(1e-6), '-r')
% xline(log10(1e-9), '-r')









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







