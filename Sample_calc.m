
% TODO: need rand() simulation
clc

H = 200e-6; % m
D = 10e-3; % m
S = pi*(D/2)^2; % m^2
Eps = 10000;

Cap = 8.85e-12*Eps*S/H % F


freq = 1e0; % Hz

R = 1/(2*pi*Cap*freq);

V = 1;

I = V/R











