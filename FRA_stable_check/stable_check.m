

classdef stable_check < handle
    properties (Access = private)
        SR860_handle
        X_old
        Y_old
        Timer
        Stable_timeout
        Delta_limit
    end

    methods (Access = public)
        function obj = stable_check(SR860_handle)
            obj.SR860_handle = SR860_handle;
            obj.X_old = inf;
            obj.Y_old = inf;
            obj.Timer = tic; % init self timer
            obj.Stable_timeout = 10; % s
            obj.Delta_limit = 50/1e6;
        end

        function stable = test(obj)
            [X, Y] = obj.get_data();
            if X ~= 0
                Delta_X = (X - obj.X_old)/X;
            else
                Delta_X = 0;
            end
            if Y ~= 0
                Delta_Y = (Y - obj.Y_old)/Y;
            else
                Delta_Y = 0;
            end
            obj.X_old = X;
            obj.Y_old = Y;
            Delta = abs(Delta_X) + abs(Delta_Y);

            disp([num2str(X) ' ' num2str(obj.X_old) ' ' num2str(Y) ' ' num2str(obj.Y_old) ])
%             disp([num2str(Delta_X) ' ' num2str(Delta_Y)])

%             DISP_DELTA(Delta, obj.Delta_limit, "ppm");

            if Delta < obj.Delta_limit
                stable = true;
            else
                stable = false;
            end

            if toc(obj.Timer) > obj.Stable_timeout
                disp('TIMEOUT TIMEOUT TIMEOUT TIMEOUT TIMEOUT')
                stable = true;
            end

        end
    end

    methods (Access = private)
        function [X, Y] = get_data(obj)
            SR860 = obj.SR860_handle;
            [X, Y] = SR860.data_get_XY();
        end
    end

end

