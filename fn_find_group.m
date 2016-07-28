
function fn_find_group(filepath,names,nclique)

fprintf('fn_find_group.... ');

load([filepath, '\features\match.mat']);
load([filepath, '\features\sift_total.mat']);

nframes = size(names,1);

% make a similarity matrix S
Si = zeros(nmatches,1);
Sj = zeros(nmatches,1);
Ss = ones(nmatches,1);
idx = 1;
for i=1:nframes
    for j=i+1:nframes
        nnmatches = size(M{i,j},2);
        ms = M{i,j};
        if size(ms,2)==0
            continue;
        end
        mi = ms(1,:) + nfeatcum(i);
        mj = ms(2,:) + nfeatcum(j);
        s = ms(3,:);
        Si(idx:idx+nnmatches-1) = mi;
        Sj(idx:idx+nnmatches-1) = mj;
        Ss(idx:idx+nnmatches-1) = s;
        idx = idx+nnmatches;
    end
end

fid = fopen([filepath '\features\match.grh'],'w');
fprintf(fid,'%d,%d,\r\n',[[Si;Sj],[Sj;Si]]');
fclose(fid);

% execute external binary
MIN_CLIQUE_NUM = min(nframes,nclique);
system(['runmaximalclique ' filepath ' ' num2str(MIN_CLIQUE_NUM)]);

% read output
text = fileread([filepath '\features\match_maximal_clique.grh']);
text = regexp(text,'[^\n]*','match');

nmatch = size(text,2);

sizes = zeros(nmatch,1);
tempcell = cell(nmatch,1);
for i=1:nmatch
    temp = text{i};
    temp2 = regexp(temp,'[\S]*','match');
    nelement = size(temp2,2);
    vec = zeros(nelement,1);
    for j=1:nelement
        vec(j) = str2double(temp2{j});
    end
    tempcell{i} = vec;
    sizes(i) = nelement;
end

[sizes,comid] = sort(sizes,'descend');

nneighvec = sizes;

featsort = cell(nmatch,1);
for i=1:nmatch
    id = comid(i);
    featsort{i} = tempcell{id};
end

save([filepath, '\features\selected.mat'],'featsort','nneighvec');

fprintf('done.\n');