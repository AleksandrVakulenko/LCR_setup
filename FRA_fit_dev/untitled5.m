


% SX = 0.92;
% SY = -0.18;
SX = 0;
SY = 0;

X_arrS = X_arr - SX;
Y_arrS = Y_arr - SY;

A_arrS = sqrt(X_arrS.^2 + Y_arrS.^2);
P_arrS = atan2(Y_arrS, X_arrS)*180/pi;

% P_arrSR = P_arrS-Angle;
% P_arrSR(1)
% P_arrS(1)
P_arrSR = P_arrS;

X_arrSR = A_arrS .* cosd(P_arrSR);
Y_arrSR = A_arrS .* sind(P_arrSR);



cla
hold on
plot(X_arr, Y_arr, '.-')
plot(X_arrSR, Y_arrSR, '.-')
% axis equal
grid on
xline(0)
yline(0)
% ylim([-1.1 1.1])
% xlim([-1.1 1.1])
drawnow















