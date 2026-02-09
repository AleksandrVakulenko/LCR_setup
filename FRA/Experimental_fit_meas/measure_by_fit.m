function [Amp_out, Phase_out] = measure_by_fit(Ammeter, freq)

FD = Fit_dev(Ammeter, freq);

if freq < 1 % FIXME: !!!
    time_limit = 3/freq;
else
    time_limit = 1;
end


Draw = false;

if Draw
    figure
end

FD.run();
try
    pause(0.1);

    X_arr = [];
    Y_arr = [];
    dX_arr = [];
    dY_arr = [];
    stop = false;

    Amp_out = [];
    Phase_out = [];

    local_time_start = tic;
    while ~stop

        time_passsed = toc(local_time_start);
        if time_passsed > time_limit
            stop = true;
        end

        [X, Y, dX, dY, status] = FD.data_get_XY();
        if ~status
            stop = true;
        else
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

            disp(num2str(dAmp/Amp*1e6))
            %     disp([num2str(dX/Amp) '   ' num2str(dY/Amp) '   ' num2str(dAmp/Amp*1e6)])
            %     disp([num2str(X) '±' num2str(dX) ' / '...
            %           num2str(Y) '±' num2str(dY)])

            if Draw
                subplot(2, 1, 1)
                hold on
                cla
                %     plot(X_arr)
                errorbar(X_arr, dX_arr)

                subplot(2, 1, 2)
                hold on
                cla
                %     plot(Y_arr)
                errorbar(Y_arr, dY_arr)

                drawnow
            end
        end

    end

catch err
    FD.stop();
    rethrow(err)
end

FD.stop();

Amp_out = Amp;
Phase_out = atan2(Y, X)*180/pi;

end