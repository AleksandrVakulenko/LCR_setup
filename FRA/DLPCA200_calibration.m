% Lockin_model = "SR844_dev";
% Lockin_address = 8;
% SR844 = feval(Lockin_model, Lockin_address);

function experimental_setup = DLPCA200_calibration()

% FIXME: test version on freq list
[freq_list1] = freq_list_gen(10e3, 100e3, 13);
[freq_list2] = freq_list_gen(1.0, 8e3, 50);
[freq_list3] = freq_list_gen(0.2, 0.8, 4);
freq_list = [freq_list1 freq_list2 freq_list3];

experimental_setup.lockin.model = "SR860";
experimental_setup.lockin.class = "SR860_dev";
experimental_setup.lockin.address = 4; % FIXME

experimental_setup.I2V_converter.model = "DLPCA200";
experimental_setup.I2V_converter.class = "DLPCA200_dev";
experimental_setup.I2V_converter.address = 3; % FIXME
experimental_setup.I2V_converter.phase_inv = "non_inv";



experimental_setup.freq_list = freq_list;
experimental_setup.sample_voltage = 1.0; % V FIXME
experimental_setup.divider_value = 0.1;

end








