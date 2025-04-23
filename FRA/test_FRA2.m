% Date: 2025.04.23
%
% ----INFO----:
% FRA measurement of calibration resistors
%
% ----TODO----:
%  1)
%  2)
%  3)
% ------------

% 01) 3L  R = 1000    V = 1.0   (10.0%)
% 02) 4L  R = 1000    V = 0.5   (50.0%)
% 03) 5H  R = 1000    V = 0.05  (50.0%)
% 06) 6H  R = 1000000 V = 1.0   (10.0%)
% 07) 7H  R = 1000000 V = 0.5   (50.0%)
% 08) 8H  R = 1000000 V = 0.05  (50.0%)
% 09) 9H  R = 1000000 V = 0.005 (50.0%)

Calibration_voltage = [1.0
                       0.5
                       0.05
                       1.0
                       0.5
                       0.05
                       0.005];

Calibration_res = [1000
                   1000
                   1000
                   1e6
                   1e6
                   1e6
                   1e6];

Calibration_sense_level = [3, 4, 5, 6, 7, 8, 9];



%%
% error('UPDATE folder')
main_save_folder = '..\..\test_results_2025_04_23\';
mkdir(main_save_folder);
%%
clc

Calibration_repeat = 3;

for Cal_N = [1, 2, 3] %[4, 5, 6, 7]
    R_test = Calibration_res(Cal_N); % Ohm / 1e3, 1e6, 100e6, 1e9
    Sense_Level = Calibration_sense_level(Cal_N); % 3(L), 4()L), 5(H), 6(H), 7(H), 8(H), 9(H)
    Voltage_gen = Calibration_voltage(Cal_N); % V

    local_save_folder = ['Calibration_N_' num2str(Cal_N, "%02u") '\'];
    save_file_folder = [main_save_folder local_save_folder];
    mkdir(save_file_folder);

    for Cal_rep_i = 1:Calibration_repeat

        experimental_setup = DLPCA200_calibration();

        Delta_limit = 50e-6;
        save_files_flag = true;
        save_stable_data = false;

        % Voltage_gen = experimental_setup.sample_voltage; % V
        DLPCA200_COM_PORT = experimental_setup.I2V_converter.address;
        freq_list = experimental_setup.freq_list;
        Phase_inv = experimental_setup.I2V_converter.phase_inv;
        Divider_value = experimental_setup.divider_value;
        Ammeter_type = get_ammeter_variants("DLPCA200");

        Ammeter_class = experimental_setup.I2V_converter.class;

        if save_files_flag
            filename = [save_file_folder 'cfile_' ...
                num2str(Cal_N, '%02u') '_' ...
                num2str(Cal_rep_i, '%02u') ...
                '_R.mat'];
        end

        % DEV INIT
        SR860 = SR860_dev(4);
        try
            Ammeter = feval(Ammeter_class, DLPCA200_COM_PORT);
            Ammeter.start_of_measurement();
        catch err
            delete(SR860);
            disp('Ammeter init error')
            rethrow(err)
        end
        pause(0.5); % FIXME: debug

        % MAIN ------------------------------------------------------------------------
        Main_error = [];
        try
            SR860_set_common_profile(SR860, Phase_inv);
            %     Current_max = Voltage_gen/R_test;
            Sense_V2C = Ammeter.set_sensitivity(Sense_Level);
            find_best_sense(SR860, Voltage_gen);
            Fig = FRA_plot(freq_list, 'I, A', 'Phase, °');

            Time_arr = zeros(size(freq_list));
            Data = FRA_data('I, [A]');
            Timer = tic;
            for i = 1:numel(freq_list)
                freq = freq_list(i);
                disp(' ')
                disp(['freq = ' num2str(freq) ' Hz'])

                save_pack = struct('comment', "real run", 'freq_list', freq_list, ...
                    'freq', freq, 'i', i);
                if ~save_stable_data
                    save_pack = [];
                end

                [Amp, Phase] = Lock_in_measure(SR860, ...
                    Voltage_gen, freq, Delta_limit, "fine", save_pack);

                Amp = Amp*Sense_V2C*sqrt(2)/Divider_value;
                %         Amp = Voltage_gen./Amp;
                time = toc(Timer);

                Time_arr(i) = time;
                Data.add(freq, "R", Amp, "Phi", Phase);

                Data_corr = Data.correction();

                Fig.replace_FRA_data(Data);
            end
            % END MAIN --------------------------------------------------------------------
        catch Main_error

        end

        SR860.set_gen_config(0.001, 1e3);
        delete(SR860);

        Ammeter.end_of_measurement();
        delete(Ammeter);


        if isempty(Main_error)
            disp("Finished without errors")
            Time_passed = Time_arr(end);
            [Time_pred_mean ,Time_pred_min, Time_pred_max] = time_predictor(freq_list);
            %     disp(['Minimum time = ' num2str(min_time) ' s']);
            disp(['Time prediction = ' num2str(Time_pred_mean) ' s']);
            disp(['Time passed = ' num2str(Time_passed) ' s']);
            disp(['ratio: ' num2str(Time_passed/Time_pred_mean, '%0.2f')]);

            if save_files_flag
                close(gcf);
                [F_arr, A_arr, P_arr] = Data.RPhi;
                %         save(filename, "A_arr", "P_arr", "F_arr", "Time_arr", "Sense_V2C")
                save(filename); % NOTE: SAVE ALL DATA!
            end

        else
            rethrow(Main_error);
        end


    end
end

