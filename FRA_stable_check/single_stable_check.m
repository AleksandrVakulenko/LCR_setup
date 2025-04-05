

%TODO:
% 1) replace array by single variables

classdef single_stable_check < handle
    properties
        Delta_limit
        Init_num
        Num = 0
        Max = -inf
        Min = inf
        Prev_v = NaN
    end

    methods
        function obj = single_stable_check(Init_num, Delta_limit)
            arguments
                Init_num (1,1) double ...
                    {mustBeGreaterThanOrEqual(Init_num, 2)} = 10;
                Delta_limit (1,1) double ...
                    {mustBeGreaterThan(Delta_limit, 0)} = 50/1e6;
            end
            obj.Init_num = Init_num;
            obj.Delta_limit = Delta_limit;
        end

        function [stable, Delta] = test(obj, v)
            obj.Num = obj.Num + 1;
            obj.update_max_min(v);

            if obj.Num < obj.Init_num
                stable = false;
                Delta = inf;
            else
                Span = obj.Max - obj.Min;
                if Span ~= 0
                    Delta = abs(obj.Prev_v - v)/Span;
                else
                    Delta = 0;
                end
                obj.Prev_v = v;

                if Delta < obj.Delta_limit
                    stable = true;
                else
                    stable = false;
                end
            end


        end

        function draw(obj)
            plot(obj.array, 'LineWidth', 1);
        end

    end

    methods (Access = private)
        function update_max_min(obj, v)
            if v > obj.Max
                obj.Max = v;
            end
            if v < obj.Min
                obj.Min = v;
            end
        end
    end

end






