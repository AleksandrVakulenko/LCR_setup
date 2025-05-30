% Date: 2025.04.05
%
% ----INFO----:
% Class for check SR860 data stability.
% works with two single_stable_check classes
%   for X and Y outputs
%
% ----SETTINGS----:
% 1) SR860_handle < handle to SR860
% 2) Delta_limit < limit of relative stability (default: 50e-6)
% 3) Disp_mode < "1", "%", "ppm", "none" (default: "ppm")
% 4) Init_num < number of reads before start actual testing (default: 10)
% 5) timeout_s < after this time stable is true (default: 10 [s])
% NOTE: Data_save argument is for debug only
%
% ----TODO----:
% 1) add data storage for debug
% 2) 
% ------------

classdef stable_check < handle
    properties (Access = private)
        SR860_handle
        Timer
        Stable_timeout
        Delta_limit
        Single_check_X
        Single_check_Y
        Disp_mode

        % NOTE: debug zone:
        Data_save
        Data = struct('x', [], 'y', [], 'time', [], 'delta_x', [], ...
            'delta_y', [], 'delta', [])
    end

    methods (Access = public)
        function obj = stable_check(SR860_handle, Delta_limit, Disp_mode, ...
                Data_save, Time_interval, Init_num, timeout_s)
            arguments
                SR860_handle
                Delta_limit (1,1) double ...
                    {mustBeGreaterThan(Delta_limit, 0)} = 50e-6 % 1
                Disp_mode {mustBeMember(Disp_mode, ...
                    ["1", "%", "ppm", "none"])} = "ppm"
                Data_save = []
                Time_interval = 1; % s
                Init_num (1,1) double ...
                    {mustBeGreaterThanOrEqual(Init_num, 2)} = 10;
                timeout_s (1,1) double ...
                    {mustBeGreaterThan(timeout_s, 0)} = 10 % s
            end
            if timeout_s < Time_interval
                timeout_s = Time_interval*2;
            end
            obj.SR860_handle = SR860_handle;
            obj.Timer = tic; % init self timer
            obj.Delta_limit = Delta_limit;
            obj.Disp_mode = Disp_mode;
            obj.Stable_timeout = timeout_s;
            obj.Data_save = Data_save;
            obj.Single_check_X = single_stable_check(Init_num, Delta_limit, Time_interval);
            obj.Single_check_Y = single_stable_check(Init_num, Delta_limit, Time_interval);
        end

        function stable = test(obj)
            [X, Y] = obj.get_data();
            time = toc(obj.Timer);

            [~, Delta_X] = obj.Single_check_X.test(X);
            [~, Delta_Y] = obj.Single_check_Y.test(Y);
            Delta0 = abs(Delta_X) + abs(Delta_Y);
            Delta = abs(X)*abs(Delta_X) + abs(Y)*abs(Delta_Y);

%             disp(' ')
%             disp([num2str(X) '  ' num2str(Delta_X)])
%             disp([num2str(Y) '  ' num2str(Delta_Y)])
%             disp([num2str(Delta0) '  ' num2str(Delta)])
%             disp(' ')

            stable = false;
            if Delta < obj.Delta_limit
                stable = true;
            else
                if time > obj.Stable_timeout
                    disp('Stable_check TIMEOUT TIMEOUT TIMEOUT TIMEOUT TIMEOUT:')
                    DISP_DELTA(Delta, obj.Delta_limit, 'ppm');
                    stable = true;
                end
            end
            
            if obj.Disp_mode ~= "none"
                DISP_DELTA(Delta, obj.Delta_limit, obj.Disp_mode);
            end


            
            % NOTE: debug zone:
            if ~isempty(obj.Data_save)
                obj.Data.x = [obj.Data.x X];
                obj.Data.y = [obj.Data.y Y];
                obj.Data.time = [obj.Data.time time];
                obj.Data.delta_x = [obj.Data.delta_x Delta_X];
                obj.Data.delta_y = [obj.Data.delta_y Delta_Y];
                obj.Data.delta = [obj.Data.delta Delta];
                % if stable % FIXME: save always?
                obj.save_data_file();
                % end
            end
        end
    end

    methods (Access = private)
        function [X, Y] = get_data(obj)
            SR860 = obj.SR860_handle;
            [X, Y] = SR860.data_get_XY();
        end
    end

    % NOTE: debug zone:
    methods (Access = private)
        function filename = gen_save_filename(obj)
            folder = 'Debug_stable_data';
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            dt = datetime;
            Y = num2str(dt.Year, '%04u');
            Mo = num2str(dt.Month, '%02u');
            D = num2str(dt.Day, '%02u');
            H = num2str(dt.Hour, '%02u');
            M = num2str(dt.Minute, '%02u');
            S = num2str(round(dt.Second), '%02u');
            filename = ['stable_data_' Y '_' Mo '_' D '_' H M S  '.mat'];
            filename = [folder '/' filename];
        end

        function save_data_file(obj)
            filename = obj.gen_save_filename;
            Stable_Data = obj.Data;
            Stable_Data.Delta_limit = obj.Delta_limit;
            Stable_Data.pack = obj.Data_save;
            save(filename, 'Stable_Data');
        end
    end

end

