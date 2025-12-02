function SR860_set_common_profile(SR860, phase_inv)
arguments
    SR860 SR860_dev
    phase_inv {mustBeMember(phase_inv, ["inv", "non_inv"])} = "non_inv"
end

if phase_inv == "inv"
    phase_shift = 180; % K6517b
else
    phase_shift = 0; % DLPCA-200
end

SR860.RESET();
SR860.configure_input("VOLT");
SR860.set_advanced_filter("on");
SR860.set_sync_filter('on');
SR860.set_expand(1, "XYR");
SR860.set_sync_src("INT");
SR860.set_harm_num(1);
SR860.set_filter_slope("24 dB/oct"); % FIXME: add selection
SR860.set_voltage_input_range(1);
SR860.set_detector_phase(phase_shift);
SR860.set_gen_config(100e-6, 1e3); % NOTE: gen off
end