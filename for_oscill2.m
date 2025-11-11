

Amp = 10.^(AmpDB/20);
Vin = 2;
Amp = Amp*Vin;

TanD = tand(PhaseDEG+90);

Current = Amp/100e6;
Zabs = Vin./Current;

Cap = 1./(2*pi*FreqHz.*Zabs);

figure

subplot(2, 1, 1)
plot(FreqHz, Cap, '-b')
set(gca, 'xscale', 'log')


subplot(2, 1, 2)
% plot(FreqHz, -TanD, '-b')
plot(FreqHz, PhaseDEG, '-b')
set(gca, 'xscale', 'log')


%%

Vin = 1;

Amp = Amp_sim*Vin;

TanD = tand(PhaseDEG_sim+90);

Current = Amp/100e6;
Zabs = Vin./Current;

Cap = 1./(2*pi*FreqHz_sim.*Zabs);

% figure

subplot(2, 1, 1)
hold on
plot(FreqHz_sim, Cap, '-r')
set(gca, 'xscale', 'log')


subplot(2, 1, 2)
hold on
plot(FreqHz_sim, PhaseDEG_sim, '-r')
set(gca, 'xscale', 'log')

%%



% phase_add = 0;
for i = 1:numel(PhaseDEG)-1
    Delta = PhaseDEG(i+1) - PhaseDEG(i);
    if abs(Delta) > 180
        PhaseDEG(i+1:end) = PhaseDEG(i+1:end) - Delta;
    end
end

figure
plot(FreqHz, PhaseDEG)
set(gca, 'xscale', 'log')



