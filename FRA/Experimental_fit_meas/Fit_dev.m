

classdef Fit_dev < handle
    properties
        T_arr
        V_arr
        I_arr
        Ammeter
        flag = false;
        freq
    end

    methods
        function obj = Fit_dev(Ammeter, freq)
            obj.Ammeter = Ammeter;
            obj.freq = freq;
        end

        function delete(obj)
            %obj.Ammeter.CMD_data_stream(false);
        end

        function run(obj)
            obj.Ammeter.CMD_data_stream(true);
%             obj.freq = obj.TD.get_freq();
            obj.flag = true;
        end

        function stop(obj)
            obj.Ammeter.CMD_data_stream(false);
        end
        
        function [X, Y, dX, dY, status] = data_get_XY(obj)
            status = obj.update_Aster();
            if numel(obj.T_arr) > 4
                I = obj.I_arr;
                V = obj.V_arr;
                Scale_I = max(abs(I));
                I = I/Scale_I;
                Scale_V = max(abs(V));
                V = V/Scale_V;
                [A_I, P_I, ~, ~, FR_I] = sin_fit_f(obj.T_arr, I, obj.freq);
                [A_V, P_V, ~, ~, FR_V] = sin_fit_f(obj.T_arr, V, obj.freq);
                CI_I = confint(FR_I);
                CI_I = (CI_I(2, :) - CI_I(1, :))/2;

                CI_V = confint(FR_V);
                CI_V = (CI_V(2, :) - CI_V(1, :))/2;

                dA_I = CI_I(1);
                dP_I = CI_I(4);

                dA_V = CI_V(1);
                dP_V = CI_V(4);

                A_I = A_I*Scale_I;
                dA_I = dA_I*Scale_I;
                A_V = A_V*Scale_V;
                dA_V = dA_V*Scale_V;
                Phase = P_V-P_I;
                dPhase = sqrt(dP_V^2 + dP_I^2);
                Amp = A_V/A_I;
                dAmp = abs(1/A_I) * dA_V + abs(-A_V/A_I^2)*dA_I;
                X = Amp*cos(Phase);
                dX = abs(cos(Phase))*dAmp + abs(-Amp*sin(Phase))*dPhase;
                Y = Amp*sin(Phase);
                dY = abs(sin(Phase))*dAmp + abs(Amp*cos(Phase))*dPhase;
            else
                X = [];
                Y = [];
                dX = [];
                dY = [];
            end
        end
    end

    methods(Access = private)

        function status = update_Aster(obj)

            if obj.flag
                try
                    status = true;
                    [T, V, I] = obj.Ammeter.get_CV();
                    obj.T_arr = [obj.T_arr T];
                    obj.V_arr = [obj.V_arr V];
                    obj.I_arr = [obj.I_arr I];
                catch
                    status = false;
                end
            else
                error('data stream is not initiated (Fit_dev)')
            end
        end


        function status = update(obj)
            if obj.flag
                [T, V, I] = obj.Ammeter.get_CV();
                status = ~isempty(T);
                obj.T_arr = [obj.T_arr T];
                obj.V_arr = [obj.V_arr V];
                obj.I_arr = [obj.I_arr I];
%                 numel(obj.T_arr)
            else
                error('data stream is not initiated (Fit_dev)')
            end
        end
    end

end






