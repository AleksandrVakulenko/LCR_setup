

classdef SR860_dummy < handle
properties
    X_arr;
    Y_arr;
    ind = 0;
end

methods
    function obj = SR860_dummy(X, Y)
        obj.X_arr = X;
        obj.Y_arr = Y;
    end
    
    function [X, Y] = data_get_XY(obj)
        obj.ind = obj.ind + 1;
        i = obj.ind;
        if i <= numel(obj.X_arr)
            X = obj.X_arr(i);
            Y = obj.Y_arr(i);
        else
            X = NaN;
            Y = NaN;
        end
%         pause(0.02);
    end
end

end







