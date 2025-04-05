

%TODO:
% 1) replace array by single variables

classdef single_stable_check < handle
    properties
        array
        Delta_limit
        Init_num
    end

    methods
        function obj = single_stable_check(Init_num, Delta_limit)
            arguments
                Init_num (1,1) double {mustBeGreaterThan(Init_num, 2)} = 10;
                Delta_limit (1,1) double ...
                    {mustBeGreaterThan(Delta_limit, 0)} = 50/1e6;
            end
            obj.Init_num = Init_num;
            obj.Delta_limit = Delta_limit;
        end

        function [stable, Delta] = test(obj, v)
            obj.array = [obj.array v];
            if numel(obj.array) < 10 % FIXME
                stable = false;
                Delta = inf;
                return;
            end
            
            Span = max(obj.array) - min(obj.array);
            if Span ~= 0 
                Delta = abs(obj.array(end-1) - obj.array(end))/Span;
            else
                Delta = 0;
            end
            if Delta < obj.Delta_limit
                stable = true;
            else
                stable = false;
            end
        end

        function draw(obj)
            plot(obj.array, 'LineWidth', 1);
        end

    end


end






