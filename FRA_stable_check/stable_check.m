

classdef stable_check < handle
    properties (Access = private)
        SR860_handle
        Timer
        Stable_timeout
        Delta_limit
        Single_check_X
        Single_check_Y
    end

    methods (Access = public)
        function obj = stable_check(SR860_handle)
            obj.SR860_handle = SR860_handle;
            obj.Timer = tic; % init self timer
            obj.Stable_timeout = 10; % s
            obj.Delta_limit = 50/1e6;
            obj.Single_check_X = single_stable_check();
            obj.Single_check_Y = single_stable_check();
        end

        function stable = test(obj)
            [X, Y] = obj.get_data();
            [~, Delta_X] = obj.Single_check_X.test(X);
            [~, Delta_Y] = obj.Single_check_Y.test(Y);

            Delta = abs(Delta_X) + abs(Delta_Y);

%             disp([num2str(Delta_X) ' ' num2str(Delta_Y)])
            DISP_DELTA(Delta, obj.Delta_limit, "ppm");

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

