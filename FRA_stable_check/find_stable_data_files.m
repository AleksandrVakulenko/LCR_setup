
function names_out = find_stable_data_files(folder_name)

% find all *.mat files in folder
content = {dir(folder_name).name};
if isempty(content)
    error(['Wrong path: "' folder_name '"'])
end
content(1:2) = [];
names = string(content);


is_mat = strfind(names, ".mat");
if class(is_mat) ~= "cell" % NOTE: case of single file
    is_mat = {is_mat};
end
is_mat = ~cellfun(@isempty, is_mat);
names = names(is_mat);


% Check presense of Loops field in *.mat

range = false(size(names));
for i = 1:numel(names)
    full_path = [folder_name '/' char(names(i))];
    filename = names(i);
    matObj = matfile(full_path);
    range(i) = isprop(matObj, 'Stable_Data');
    names_out(i).full_path = full_path;
    names_out(i).filename = filename;
    disp([num2str(i) '/' num2str(numel(names)) ' : ' char(names(i)) ' : ' num2str(range(i))]);
end
names_out = names_out(range);


end





