
function names = fn_get_filenames(filepath,fileextension,idx)
% idx indicates key frame indices

temp = dir([filepath, '\input\', fileextension]);

if nargin == 2
    nfiles = size(temp,1);
    names = cell(nfiles,1);
    for i=1:nfiles
        %names{i} = [filepath temp(i).name];
        names{i} = temp(i).name;
    end
elseif nargin == 3
    nfiles = numel(idx);
    names = cell(nfiles,1);
    for i=1:nfiles
        %names{i} = [filepath temp(idx(i)).name];
        names{i} = temp(idx(i)).name;
    end
end