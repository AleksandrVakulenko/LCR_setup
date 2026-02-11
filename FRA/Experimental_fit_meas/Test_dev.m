

classdef Test_dev < handle
    properties
        T_arr
        V_arr
        I_arr
        init_time = NaN
    end

    methods
        function obj = Test_dev(T_arr, V_arr, I_arr)
            obj.T_arr = T_arr;
            obj.V_arr = V_arr;
            obj.I_arr = I_arr;

        end

        function run(obj)
            obj.init_time = tic;
        end

        function stop(obj)

        end


        function CMD_data_stream(obj, status)
            if status
                obj.run();
            else
                obj.stop();
            end
        end

        
        function [T, V, I] = get_CV(obj)
            if ~isnan(obj.init_time)
                Time_passed = toc(obj.init_time);
                range = obj.T_arr < Time_passed + obj.T_arr(1);
                if ~isempty(find(range))
                    T = obj.T_arr(range);
                    V = obj.V_arr(range);
                    I = obj.I_arr(range);
                    obj.T_arr(range) = [];
                    obj.V_arr(range) = [];
                    obj.I_arr(range) = [];
                else
                    T = [];
                    V = [];
                    I = [];
                end

            else
                error('data stream is not initiated (Test_dev)')
            end

        end
    end


end
