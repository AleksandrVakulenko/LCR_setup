% Date: 2025.04.23
%
% ----INFO----:
% FRA measurement of calibration resistors
%
% ----TODO----:
%  1) Freq list generator
%  2) time predictor auto-update
%  3) Add more settings to stable_test
%  4) 
%  5) Sample info struct
%  6) Add Harm measuring
%  7)
%  8) Add lock-in I-V converter
%  9) Test lock-in I-V converter
% 10) If lock-in I-V it is the same dev handle ?!

% ----TODO (in progress)----:
%  1) sample ping
%  2) auto-range
%  3) Replace correction by interp1
%  4) FRA settings struct
% ---------------------------

% Aster calibration table
% 01) 3L  R = 1000    V = 1.0   (10.0%)
% 02) 4L  R = 1000    V = 0.5   (50.0%)
% 03) 5H  R = 1000    V = 0.05  (50.0%)
% 04) 6H  R = 1000000 V = 1.0   (10.0%)
% 05) 7H  R = 1000000 V = 0.5   (50.0%)
% 06) 8H  R = 1000000 V = 0.05  (50.0%)
% 07) 9H  R = 1000000 V = 0.005 (50.0%)

Calibration_current = [2e-3
                       250e-6
                       2.5e-6
                       20e-9
                       250e-12
                       2.5e-12];

Calibration_voltage = [2.0
                       0.25
                       0.0025
                       2.0
                       0.025
                       0.0025];

Calibration_res = [1000
                   1000
                   1000
                   100e6
                   100e6
                   1e9];

REF_FILE_NAME = ["DATA_REF_1k.mat"
                 "DATA_REF_1k.mat"
                 "DATA_REF_1k.mat"
                 "DATA_REF_100M.mat"
                 "DATA_REF_100M.mat"
                 "DATA_REF_1G.mat"];

Calibration_repeat = 6;

%%
% error('UPDATE folder')
main_save_folder = '..\..\test_results_2025_11_11\';
mkdir(main_save_folder);
%%
clc

Delta_limit = 50e-6;
save_files_flag = true;
save_stable_data = false;

for Cal_N = [1, 2, 3] % [4, 5] [6]
    R_test = Calibration_res(Cal_N); % Ohm / 1e3, 1e6, 100e6, 1e9
    %Sense_Level = Calibration_sense_level(Cal_N); % 3(L), 4()L), 5(H), 6(H), 7(H), 8(H), 9(H)
    Voltage_gen = Calibration_voltage(Cal_N); % V
    Sense_Level = Voltage_gen/R_test;

    local_save_folder = ['Calibration_N_' num2str(Cal_N, "%02u") '\'];
    save_file_folder = [main_save_folder local_save_folder];
    mkdir(save_file_folder);

    load(REF_FILE_NAME(Cal_N));

    for Cal_rep_i = 1:Calibration_repeat

        experimental_setup = Aster_calibration();

        if save_files_flag
            filename = [save_file_folder 'cfile_' ...
                num2str(Cal_N, '%02u') '_' ...
                num2str(Cal_rep_i, '%02u') ...
                '_R.mat'];
        end

        freq_list = experimental_setup.freq_list;
        Phase_inv = experimental_setup.I2V_converter.phase_inv;
        Divider_value = experimental_setup.divider_value;
        % Voltage_gen = experimental_setup.sample_voltage; % V

        % DEV INIT
        [Lockin, Ammeter] = init_devices(experimental_setup);

        % MAIN -----------------------------------------------------------------
        Main_error = [];
        try
            SR860_set_common_profile(Lockin, Phase_inv); %FIXME: refactor
            %     Current_max = Voltage_gen/R_test;
            Sense_V2C = Ammeter.set_sensitivity(Sense_Level);
            find_best_sense(Lockin, Voltage_gen); % FIXME: undone sample ping
            Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');

            Time_arr = zeros(size(freq_list)); % FIXME: create time monitor
            Data = FRA_data('I, [A]'); % FIXME: refactor this class
            Timer = tic;
            for i = 1:numel(freq_list)
                freq = freq_list(i);
                disp(' ')
                disp(['freq = ' num2str(freq) ' Hz'])

                if ~save_stable_data
                    save_pack = [];
                else
                    save_pack = struct('comment', "real run", ...
                        'freq_list', freq_list, 'freq', freq, 'i', i);
                end

                % FIXME: Lock_in_measure is bad!
                [Amp, Phase, G_volt] = Lock_in_measure(Lockin, ...
                    Voltage_gen, freq, Delta_limit, "fine", save_pack);

                Amp = Amp*Sense_V2C*sqrt(2)/Divider_value;

                % FIXME: add calibration correction here

                % FIXME: add impedance calc
                Amp = G_volt./Amp;

                time = toc(Timer);
                Time_arr(i) = time;
                Data.add(freq, "R", Amp, "Phi", Phase);

%                 Data_corr = Data.correction();

                Fig.replace_FRA_data([Data Data_ref]);
            end
            % END MAIN --------------------------------------------------------------------
        catch Main_error

        end

        Lockin.terminate();
        delete(Lockin);

        Ammeter.terminate();
        delete(Ammeter);


        if isempty(Main_error)
            disp("Finished without errors")
            Time_passed = Time_arr(end);
            time_predictor_disp(freq_list, Time_passed)

            if save_files_flag % FIXME: need refactor
                close(gcf);
                [F_arr, A_arr, P_arr] = Data.RPhi;
                %         save(filename, "A_arr", "P_arr", "F_arr", "Time_arr", "Sense_V2C")
                save(filename); % NOTE: SAVE ALL DATA!
            end

        else
            rethrow(Main_error);
        end


    end % Calibration loops end
end

