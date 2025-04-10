



figure

slider1 = uicontrol('style','slider');
slider1.InnerPosition = [20 5 300 20];

stop = false
while ~stop
    
Angle = 90*get(slider1, 'value')-45

% SX = 0.92;
% SY = -0.18;
SX = 0;
SY = 0;
X_arrS = X_arr - SX;
Y_arrS = Y_arr - SY;

A_arrS = sqrt(X_arrS.^2 + Y_arrS.^2);
P_arrS = atan2(Y_arrS, X_arrS)*180/pi;

P_arrSR = P_arrS-Angle;
% P_arrSR(1)
% P_arrS(1)
% P_arrSR = P_arrS;

X_arrSR = A_arrS .* cosd(P_arrSR);
Y_arrSR = A_arrS .* sind(P_arrSR);



cla
plot(X_arrSR, Y_arrSR, '.-')
axis equal
grid on
xline(0)
yline(0)
% ylim([-0.5 0.5])
% xlim([-0.5 0.5])
drawnow

end



%%


Angle = 30;

SX = 0;
SY = 0;
X_arrS = X_arr - SX;
Y_arrS = Y_arr - SY;

A_arrS = sqrt(X_arrS.^2 + Y_arrS.^2);
P_arrS = atan2(Y_arrS, X_arrS)*180/pi;

P_arrSR = P_arrS-Angle;
% P_arrSR(1)
% P_arrS(1)
% P_arrSR = P_arrS;

X_arrSR = A_arrS .* cosd(P_arrSR);
Y_arrSR = A_arrS .* sind(P_arrSR);


plot(F_arr_log, A_arrS, '.-');
plot(F_arr_log, P_arrSR, '.-');











