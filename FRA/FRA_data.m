


classdef FRA_data < handle
    properties
        freq = []
        X = []
        Y = []
    end

    methods (Access = public)
        function obj = FRA_data(freq, data)
            arguments
                freq {mustBeNumeric(freq), mustBeGreaterThan(freq, 0)} = []
                data.R {mustBeNumeric(data.R)} = []
                data.Phi {mustBeNumeric(data.Phi)} = []
                data.X {mustBeNumeric(data.X)} = []
                data.Y {mustBeNumeric(data.Y)} = []
            end
            if ~isempty(freq)
                obj.add(freq, 'R', data.R, 'Phi', data.Phi, ...
                    'X', data.X, 'Y', data.Y);
            end
        end

        function add(obj, freq, data)
            arguments
                obj
                freq {mustBeNumeric(freq), mustBeGreaterThan(freq, 0), ...
                    mustBeVector(freq)} = []
                data.R {mustBeNumeric(data.R)} = []
                data.Phi {mustBeNumeric(data.Phi)} = []
                data.X {mustBeNumeric(data.X)} = []
                data.Y {mustBeNumeric(data.Y)} = []
            end
            if ~isempty(freq)
                obj.freq = [obj.freq freq];
                if ~isempty(data.R) && ~isempty(data.Phi)
                    data.X = data.R .* cosd(data.Phi);
                    data.Y = data.R .* sind(data.Phi);
                    obj.X = [obj.X data.X];
                    obj.Y = [obj.Y data.Y];
                elseif ~isempty(data.X) && ~isempty(data.Y)
                    obj.X = [obj.X data.X];
                    obj.Y = [obj.Y data.Y];
                else
                    error('wrong arguments')
                end
            end
            obj.sort_data();
        end

        function union(obj, fra_data)
            arguments
                obj
                fra_data FRA_data
            end
            [f, x, y] = fra_data.XY();
            obj.add(f, "X", x, "Y", y);
        end

        function [freq, X, Y] = XY(obj)
            freq = obj.freq;
            X = obj.X;
            Y = obj.Y;
        end

        function [freq, R, Phi] = RPhi(obj)
            freq = obj.freq;
            R = sqrt(obj.X.^2 + obj.Y.^2);
            Phi = atan2(obj.Y, obj.X);
            Phi = phase_shift_correction(Phi);
        end
    end


    methods (Access = private)
        function sort_data(obj)
            [obj.freq, Perm] = sort(obj.freq);
            obj.X = obj.X(Perm);
            obj.Y = obj.Y(Perm);
        end

    end

end






function P_arr = phase_shift_correction(P_arr)
D_P_Arr = diff(P_arr);
range_p = D_P_Arr > 180;
range_n = D_P_Arr < -180;

range_p = [false range_p];
range_n = [false range_n];

Phase_shift_array = zeros(size(P_arr));
Phase_shift = 0;
for i = 1:numel(range_p)
    if range_p(i)
        Phase_shift = Phase_shift - 360;
    end
    if range_n(i)
        Phase_shift = Phase_shift + 360;
    end
    Phase_shift_array(i) = Phase_shift;
end

P_arr = P_arr + Phase_shift_array;
end


