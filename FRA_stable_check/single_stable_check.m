

classdef single_stable_check < handle
    properties
        array
        Delta_limit
    end

    methods
        function obj = single_stable_check(Delta_limit)
            obj.Delta_limit = Delta_limit;
        end

        function stable = test(obj, v)
            stable = false;
            obj.array = [obj.array v];
            if numel(obj.array) < 10 % FIXME
                return;
            end
            
            Mean = mean(obj.array);
            Delta = abs(obj.array(end-1) - obj.array(end))/Mean;
            if Delta < obj.Delta_limit
                stable = true;
            end
        end

    end


end






