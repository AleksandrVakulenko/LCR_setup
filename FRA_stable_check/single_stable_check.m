% Date: 2025.04.05
%
% ----INFO----:
% Class for check single variable stability.
%
% ----SETTINGS----:
% 1) Delta_limit < limit of relative stability
% 2) Init_num < number of reads before start actual testing
% 
% ----TODO----:
% ------------

classdef single_stable_check < handle
    properties
        Delta_limit
        Init_num
        Num = 0
        Max = -inf
        Min = inf
        Prev_v = NaN
        Array = [];
        Time = [];
        Timer
        Time_interval
    end

    methods (Access = public)
        function obj = single_stable_check(Init_num, Delta_limit, Time_interval)
            arguments
                Init_num (1,1) double ...
                    {mustBeGreaterThanOrEqual(Init_num, 2)} = 10;
                Delta_limit (1,1) double ...
                    {mustBeGreaterThan(Delta_limit, 0)} = 50/1e6;
                Time_interval = 1; % s
            end
            obj.Init_num = Init_num;
            obj.Delta_limit = Delta_limit;
            obj.Timer = tic;
            obj.Time_interval = Time_interval;
        end

        function [stable, Delta] = test(obj, v)
            obj.Num = obj.Num + 1;
            obj.update_max_min(v);
            
            time = toc(obj.Timer);
            obj.Time = [obj.Time time];
            obj.Array = [obj.Array v];


            if obj.Num < obj.Init_num
                stable = false;
                Delta = inf;
            else
                range = obj.Time >= (obj.Time(end) - obj.Time_interval);
                Array_part = obj.Array(range);
                MM = minmax(Array_part);
                Span = MM(2) - MM(1);
                Mean = mean(Array_part);
                
                Delta = Span/Mean;
%                 disp([num2str(Span) '   ' num2str(Mean) '   ' num2str(Delta)])

                if Delta < obj.Delta_limit
                    stable = true;
                else
                    stable = false;
                end
            end


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






