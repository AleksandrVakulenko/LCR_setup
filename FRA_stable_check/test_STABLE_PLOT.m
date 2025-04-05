
clc

folder = 'Debug_stable_data/';
names_out = find_stable_data_files(folder);

fig = [];
for i = 1:numel(names_out)
load(names_out(i).full_path);

fig = plot_stable_graph(Stable_Data, fig);

pause(0.5)
end



