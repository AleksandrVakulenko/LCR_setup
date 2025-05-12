

function [Lockin, Ammeter] = init_devices(experimental_setup)
    
    Lockin_class = experimental_setup.lockin.class;
    Lockin_address = experimental_setup.lockin.address;
    Ammeter_class = experimental_setup.I2V_converter.class;
    Ammeter_address = experimental_setup.I2V_converter.address;
    
    
    Lockin = feval(Lockin_class, Lockin_address);
    try
        Lockin.initiate();
    catch err
        delete(Lockin)
        rethrow(err);
    end
    
    try
        Ammeter = feval(Ammeter_class, Ammeter_address);
        Ammeter.initiate();
    catch err
        delete(Lockin);
        disp('Ammeter init error')
        rethrow(err)
    end

    pause(0.5); % FIXME: debug


end