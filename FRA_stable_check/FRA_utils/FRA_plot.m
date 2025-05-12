
% FIXME: need refactor of functions struct

% TODO:
% 1) Add ability to get/set/delete data
% 2) Add multiple data
% 3) Add ability to replace label

classdef FRA_plot < handle

    properties (Access = private)
        fig
        axis_top
        axis_bot
        freq_list
        style
        ylabel_top
        ylabel_bot
        nonconst_freq_list
    end

    methods
        function obj = FRA_plot(freq_list, ylabel_top, ylabel_bot, style)
            arguments
                freq_list {mustBeNumeric(freq_list)} = []
                ylabel_top (1,1) string = "Amp, a.u."
                ylabel_bot (1,1) string = "Phase, °"
                style {mustBeMember(style, ["SI", "POW", "auto"])} = "auto"
            end
            if isempty(freq_list)
                freq_list = [1 10];
                obj.nonconst_freq_list = true;
            else
                obj.nonconst_freq_list = false;
            end
            

            obj.freq_list = freq_list;
            obj.style = style;
            obj.ylabel_top = ylabel_top;
            obj.ylabel_bot = ylabel_bot;

            obj.fig = figure('Position', [440 240 690 745], 'Resize', 'on');

            subplot('Position', [0.093    0.568    0.85    0.40])
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_top, obj.style)

            subplot('Position', [0.093    0.086    0.85    0.40])
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_bot, obj.style)

            ax_arr = obj.fig.Children;
            obj.axis_top = ax_arr(2);
            obj.axis_bot = ax_arr(1);

        end

        function replace(obj, F_arr, A_arr, P_arr)
            if obj.nonconst_freq_list
                obj.freq_list = F_arr;
            end
            figure(obj.fig)

            axes(obj.axis_top)
            cla
            plot(F_arr, A_arr, '.-b', 'MarkerSize', 8);
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_top, obj.style)

            axes(obj.axis_bot)
            cla
            plot(F_arr, P_arr, '.-b', 'MarkerSize', 8);
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_bot, obj.style)

            drawnow
        end

        function replace_FRA_data(obj, Data)
            [F_arr, A_arr, P_arr] = Data.RPhi;
            obj.replace(F_arr, A_arr, P_arr);
        end

    end

end







