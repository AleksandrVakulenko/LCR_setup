


classdef FRA_data < handle
    properties
        unit
        freq = []
        X = []
        Y = []
    end

    methods (Access = public)
        function obj = FRA_data(unit, freq, data)
            arguments
                unit {mustBeTextScalar};
                freq {mustBeNumeric(freq), mustBeGreaterThan(freq, 0)} = []
                data.R {mustBeNumeric(data.R)} = []
                data.Phi {mustBeNumeric(data.Phi)} = []
                data.X {mustBeNumeric(data.X)} = []
                data.Y {mustBeNumeric(data.Y)} = []
            end
            obj.unit = unit;
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
            Phi = atan2(obj.Y, obj.X)*180/pi;
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









