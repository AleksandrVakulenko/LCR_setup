

function Data_out = interp_FRA_data(Data_in, Data_target)

[Freq_tg, ~, ~] = Data_target.RPhi();
[Freq_in, R_in, Phi_in] = Data_in.RPhi();

R_new = interp1(Freq_in, R_in, Freq_tg);
Phi_new = interp1(Freq_in, Phi_in, Freq_tg);

Data_out = FRA_data(Data_in.unit, Freq_tg, "R", R_new, "Phi", Phi_new);

end



function Data_out = interp_FRA_data(Data, Target)

Freq_tg = Target.freq;

Freq = Data.freq;
X = Data.X;
Y = Data.Y;

X_out = interp1(Freq, X, Freq_tg);
Y_out = interp1(Freq, Y, Freq_tg);

Data_out = FRA_data(Data.unit, Freq_tg, "X", X_out, "Y", Y_out);

end


