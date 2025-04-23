function find_best_sense(SR860, Voltage_gen)
Delta_limit = 200e-6;

freq = 10;

SR860.set_sensitivity(1, "voltage"); % FIXME: need auto-mode
[Amp, ~] = Lock_in_measure(SR860, ...
    Voltage_gen, freq, Delta_limit, "common", []);

if Amp < 0.001
    SR860.set_sensitivity(0.002, "voltage"); % FIXME: need auto-mode
    [Amp, ~] = Lock_in_measure(SR860, ...
        Voltage_gen, freq, Delta_limit, "common", []);
end

if Amp < 1/1.2
    Amp = Amp*1.2;
end

SR860.set_sensitivity(Amp, "voltage");

%     disp(['Amp = ' num2str(Amp) ' V'])
end