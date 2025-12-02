
Fern.load(...)

%%


experimental_setup = Aster_calibration();

Ammeter_class = experimental_setup.I2V_converter.class;
Ammeter_address = experimental_setup.I2V_converter.address;


%%

clc

N = 50;
Array_result = zeros(1, N);

for i = 1:N

    k = 0;
    stop = false;
    while(~stop)
        try
            Ammeter = feval(Ammeter_class, Ammeter_address);
            stop = true;
        catch
            k = k + 1;
            disp(['Fail ' num2str(k) ' (i: ' num2str(i) ')']);
            pause(0.25);
            continue
        end
    end

    Array_result(i) = k;

    delete(Ammeter);
    pause(1);

end
%%






