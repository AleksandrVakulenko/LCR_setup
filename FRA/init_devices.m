

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
    
    Ready = false;
    for i = 1:10
        e = [];
        try
            Ammeter = feval(Ammeter_class, Ammeter_address);
            Ammeter.initiate();
        catch e
            disp(['----- Ammeter init error (try ' num2str(i) ') -----']);
            disp(e.message);
            pause(1.0)
        end
        if isempty(e)
            Ready = true;
            break
        end
    end
    
    if ~Ready
        delete(Lockin);
        error("Ammeter init error")
    end
    
    pause(0.5); % FIXME: debug


end