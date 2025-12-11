


Fern.load('aDevice')
Fern.load('FRA_tools')
Ammeter_class = "Aster_dev";

if isunix
    Ammeter_address = "/dev/ttyACM0";
elseif ispc
    Ammeter_address = 5;
else
    error('OS error')
end

%%

clc

N = 50;
Array_result = [];

for i = 1:N

    k = 0;
    stop = false;
    while(~stop)
        try
            Ammeter = feval(Ammeter_class, Ammeter_address);
            stop = true;
            disp(['OK (i: ' num2str(i) ')']);
        catch err
            warning(err.message)
            k = k + 1;
            disp(['Fail ' num2str(k) ' (i: ' num2str(i) ')']);
            pause(0.25);
            continue
        end
    end

    Array_result(i) = k;

    pause(0.5)
    delete(Ammeter);
    pause(0.5);

end
%%

hold on

load('../Fail_test_FTI_backside.mat')
plot(Array_result, '.-')

load('../Fail_test_FTI_frontside_3.mat')
plot(Array_result, '.-')

load('../Fail_test_FTI_frontside_2.mat')
plot(Array_result, '.-')

load('../Fail_test_FTI_frontside_2_on_table.mat')
plot(Array_result, '.-')

%%

clc

Ammeter = feval(Ammeter_class, Ammeter_address);

stop = false;
LT = tic;
while(~stop)
time = toc(LT);
if time > 50
    stop = true;
end

Val = Ammeter.get_current_value();

disp(Val);

end

delete(Ammeter);
disp('END END END')





