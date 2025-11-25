
clc

Ranges = 10.^[-3, -4, -5, -6, -7, -8, -9, -10, -11]*10;



V_array = [1, 0.5, 0.05, 0.005, 500e-6, 50e-6];

R_array = [1e6, 1e3, 100e6, 1e9];



for k = 1:numel(Ranges)
I_max = Ranges(k)*0.9;
I_min = Ranges(k)*0.1;
stop = false;
for R = R_array
    for V = V_array
        I = V/R;
        if I <= I_max && I >= I_min
            Prc = I/Ranges(k)*100;
            Range_name = num2str(-log10((Ranges(k))/10));
            disp(['(' num2str(k) '/' num2str(numel(Ranges)) ')' ...
                ' ' Range_name ' '...
                ' R = ' ...
                num2str(R) ' V = ' num2str(V) ' ' num2str(Prc, "%3.1f")])
            stop = true;
        end
        if stop
            break;
        end
    end
    if stop
        break;
    end
end

end



