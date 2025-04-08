function [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, ...
    Freq_num, Freq_permutation)

freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);
freq_list = flip(freq_list);
periods = 1./freq_list;
min_time = sum(periods);

if Freq_permutation
    freq_list = freq_list(randperm(length(freq_list)));
end

end