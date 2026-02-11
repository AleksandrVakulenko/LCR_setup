

clc

load('../../test_results_2026_02_09/1000_1458.mat')


% part 1 from Fit_dev.m

Scale_I = 1/1000;
Scale_V = 1;


[A_I, P_I, ~, ~, FR_I] = sin_fit_f(T_a, -I, Freq);
[A_V, P_V, ~, ~, FR_V] = sin_fit_f(T_a, V, Freq);


%                 disp(['A_I = ' num2str(A_I) ' ' ...
%                       'P_I = ' num2str(P_I*1e9) ' ' ...
%                       'A_V = ' num2str(A_V) ' ' ...
%                       'P_V = ' num2str(P_V*1e9) ' '])

%                 figure
%                 hold on
%                 plot(obj.T_arr, I)
%                 plot(obj.T_arr, V)
%                 drawnow

CI_I = confint(FR_I);
CI_I = (CI_I(2, :) - CI_I(1, :))/2;
%                 disp([num2str(CI_I(1)) ' ' num2str(CI_I(2)) ' ' num2str(CI_I(3)) ' ' num2str(CI_I(4))])

CI_V = confint(FR_V);
CI_V = (CI_V(2, :) - CI_V(1, :))/2;
%                 disp([num2str(CI_V(1)) ' ' num2str(CI_V(2)) ' ' num2str(CI_V(3)) ' ' num2str(CI_V(4))])

dA_I = CI_I(1);
dP_I = CI_I(4);

dA_V = CI_V(1);
dP_V = CI_V(4);



A_I = A_I*Scale_I;
dA_I = dA_I*Scale_I;
A_V = A_V*Scale_V;
dA_V = dA_V*Scale_V;
Phase = P_V-P_I;
dPhase = sqrt(dP_V^2 + dP_I^2);
Amp = A_V/A_I;
dAmp = abs(1/A_I) * dA_V + abs(-A_V/A_I^2)*dA_I;
Phase_rad = Phase*pi/180;
X = Amp*cos(Phase_rad);
dX = abs(cos(Phase_rad))*dAmp + abs(-Amp*sin(Phase_rad))*dPhase;
Y = Amp*sin(Phase_rad);
dY = abs(sin(Phase_rad))*dAmp + abs(Amp*cos(Phase_rad))*dPhase;





% part 2 from measure_by_fit.m

X_arr = [];
Y_arr = [];
dX_arr = [];
dY_arr = [];

X_arr = [X_arr X];
Y_arr = [Y_arr Y];
dX_arr = [dX_arr dX];
dY_arr = [dY_arr dY];

Amp = sqrt(X^2 + Y^2);
dAmp = abs(1/(2*sqrt(X^2 + Y^2))*(2*X)) * dX + ...
    abs(1/(2*sqrt(X^2 + Y^2))*(2*Y)) * dY;
dAmp_ppm = dAmp/Amp*1e6;
if dAmp_ppm < 50
    stop = true;
end

% disp([num2str(X) ' ' ...
%       num2str(dX) ' ' ...
%       num2str(Y) ' ' ...
%       num2str(dY)])


disp(num2str(dAmp/Amp*1e6))
%     disp([num2str(dX/Amp) '   ' num2str(dY/Amp) '   ' num2str(dAmp/Amp*1e6)])
%     disp([num2str(X) '±' num2str(dX) ' / '...
%           num2str(Y) '±' num2str(dY)])


Res_final = Amp;
Phase_final = atan2(Y, X)*180/pi;

disp(['R = ' num2str(Res_final, '%0.2f') ' Ohm  /  ' ...
      'Phi = ' num2str(Phase_final, '%0.4f') ' deg'])

