
clc

Freq_limit = [
200e3
200e3
8.5e3
60
0.1
0.05
]; % Hz


Current_limit = [
25e-3
500e-6
5e-6
50e-9
500e-12
5e-12
]; % A


Vin = 1; % V
Cap = 10e-12;

Freq_list = 10.^linspace(log10(0.005), log10(10e3), 30);
Freq_list = flip(Freq_list);


for i = 1:numel(Freq_list)
Freq = Freq_list(i);

Rcap = 1/(2*pi*Cap*Freq);

Current = Vin/Rcap;

Ranges_freq = Freq_limit > Freq;

Ranges_cur = Current_limit >= Current;

Ranges = Ranges_cur & Ranges_freq;

ind = find(Ranges);
if ~isempty(ind)
    ind = ind(end);
else
    ind = -1;
end

if ind ~= -1
    Part = Current./Current_limit(ind);
    disp(['Range ' num2str(ind) ' (' num2str(Part*100, '%0.4f') ')'])
else
    disp(['Range ---'])
end

end










