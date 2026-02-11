function [A, P, C, D, fitresult, gof] = sin_fit_f(Time, Signal, Freq)

Time = Time - Time(1);

Eq = ['A*sin(2*pi*(' num2str(Freq) '*(1+D/1e6))*x+P/180*pi) + C'];

[xData, yData] = prepareCurveData(Time, Signal);

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';

% FIXME: limits
%                     A      C    D[ppm]    P
opts.Lower      =  [   0   -10   -500   -180   ];
opts.StartPoint =  [   1     0   -150      0.1 ];
opts.Upper      =  [  20   +10   +500   +180   ];
% FIXME: check limits on D
% FIXME: use D only on long data


[fitresult, gof] = fit(xData, yData, ft, opts);

A = fitresult.A;
C = fitresult.C;
D = fitresult.D;
P = fitresult.P;

% disp(confint(fitresult))
end


% ft = fittype(['A*sin(2*pi*' num2str(Freq) '*x+P/180*pi) + C']);
% coeffnames(ft)