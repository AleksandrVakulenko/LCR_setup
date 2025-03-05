
DEBUG_MSG_ENABLE("enable")

clc




SR860 = SR860_dev(4);

% a = SR860.set_gen_freq(20)
% SR860.get_gen_freq;
% [a,b,c] = SR860.set_gen_amp(1.1)
% SR860.get_gen_amp;
[v,f] = SR860.set_genVF(0.01, 1000)

% SR860.set_sensitivity(1, "voltage")

delete(SR860)






%%

figure

SR860 = SR860_dev(4);

Plot_period = 20; % s
Time_arr = [];
Amp_arr = [];
Freq_arr = [];
Timer = tic;

stop = false;
while ~stop
    time = toc(Timer);
    if time>Plot_period
        stop = true;
    end
    Time_arr = [Time_arr time];
    [Amp, Freq] = SR860.get_genVF;
    Amp_arr = [Amp_arr Amp];

    cla
    plot(Time_arr, Amp_arr)
    set(gca, 'yscale', 'log')
    drawnow
end


delete(SR860)

Time_arr(end)/numel(Time_arr)








