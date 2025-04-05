
clc

time = 0:0.05:10;
X = exp(-time/0.3);
Y = zeros(size(X));

figure
hold on
plot(time, X);
plot(time, Y);

SR860 = SR860_dummy(X, Y);

sc = stable_check(SR860);

stable = sc.test;
while ~stable
    stable = sc.test;
end










