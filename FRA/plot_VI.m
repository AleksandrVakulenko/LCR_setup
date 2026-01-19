function plot_VI(t, V, I, title_str)

figure('Position', [400 280 750 490])

subplot(2, 1, 1)
plot(t, V)
title(title_str)
ylabel('V, V')
xlabel('t, s')

subplot(2, 1, 2)
plot(t, I)
ylabel('I, A')
xlabel('t, s')

end