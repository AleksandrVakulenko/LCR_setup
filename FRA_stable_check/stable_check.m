

classdef stable_check < handle
    properties (Access = private)
        SR860_handle
        Timer
        Stable_timeout
        Delta_limit
        Single_check_X
        Single_check_Y
        Disp_mode
    end

    methods (Access = public)
        function obj = stable_check(SR860_handle, Delta_limit, Disp_mode, ...
                Init_num, timeout_s)
            arguments
                SR860_handle
                Delta_limit (1,1) double ...
                    {mustBeGreaterThan(Delta_limit, 0)} = 50/1e6 % 1
                Disp_mode {mustBeMember(Disp_mode, ...
                    ["1", "%", "ppm", "none"])} = "ppm"
                Init_num (1,1) double ...
                    {mustBeGreaterThanOrEqual(Init_num, 2)} = 10;
                timeout_s (1,1) double ...
                    {mustBeGreaterThan(timeout_s, 0)} = 10 % s

            end
            obj.SR860_handle = SR860_handle;
            obj.Timer = tic; % init self timer
            obj.Delta_limit = Delta_limit;
            obj.Disp_mode = Disp_mode;
            obj.Stable_timeout = timeout_s;
            obj.Single_check_X = single_stable_check(Init_num, Delta_limit);
            obj.Single_check_Y = single_stable_check(Init_num, Delta_limit);
        end

        function stable = test(obj)
            [X, Y] = obj.get_data();
            [~, Delta_X] = obj.Single_check_X.test(X);
            [~, Delta_Y] = obj.Single_check_Y.test(Y);

            Delta = abs(Delta_X) + abs(Delta_Y);

            if obj.Disp_mode ~= "none"
                DISP_DELTA(Delta, obj.Delta_limit, obj.Disp_mode);
            end

            if Delta < obj.Delta_limit
                stable = true;
            else
                stable = false;
            end

            if toc(obj.Timer) > obj.Stable_timeout
                disp('Stable_check TIMEOUT:')
                DISP_DELTA(Delta, obj.Delta_limit, 'ppm');
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

