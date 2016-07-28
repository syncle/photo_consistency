
function fn_extract_patches_batch(filepath,names,colorchannel)


load([filepath, '\features\selected.mat']);
load([filepath, '\features\sift_total.mat']);

nselected = size(featsort,1);
nimg = numel(nfeat);

displaypatch = 1;

nframes = size(names,1);
nfeatinfoall = sum(nneighvec);
featinfoall = zeros(nfeatinfoall,3);

cnt = 1;
for i=1:nselected
       
    featidtot = featsort{i};
    nfeat = numel(featidtot);
    imgid = zeros(1,nfeat);
    featid = zeros(1,nfeat);
    for j=1:nfeat
        for k=1:nimg
            if featidtot(j) <= nfeatcum(k+1)
                break;
            end
        end
        imgid(j) = k;
        featid(j) = featidtot(j)-nfeatcum(k);

        featinfoall(cnt,:) = [imgid(j),featid(j),i];
        cnt = cnt + 1;
    end
end

[val,featinfoind] = sort(featinfoall(:,1));
featinfoallsort = featinfoall(featinfoind,:);


patchesall = cell(nframes,1);
for k=1:nframes
    fprintf('extracting patches in %05d/%05d frames\n', k, nframes);
    imgname = names{k};
    img = imread([filepath,'\input\', imgname]);
    
    if strcmp(colorchannel,'YCBCR')
        img = rgb2ycbcr(img);
    end
        
    kind = find(featinfoallsort(:,1)==k);
    tind = featinfoallsort(kind,2);
    S = load([filepath, '\features\sift_' imgname '.mat']);
    Sf = S.f(:,tind);
    x = Sf(1,:);
    y = Sf(2,:);
    s = Sf(3,:)*5;
    t = Sf(4,:);    
    patchesall{k} = fn_extract_patches(img, x, y, s, t);
end

% re-organize patches
patchescollected = cell(nselected,nframes);
cntcol = ones(nselected,1);
cntimg = ones(nframes,1);
for i=1:nfeatinfoall
    imgid = featinfoall(i,1);
    colid = featinfoall(i,3);
    patchescollected{colid,cntcol(colid)} = patchesall{imgid}{cntimg(imgid)};
    cntcol(colid) = cntcol(colid) + 1;
    cntimg(imgid) = cntimg(imgid) + 1;
end

if exist([filepath '\\patches\\'],'dir')
    rmdir([filepath '\\patches\\'],'s');
end

if displaypatch
    
    mkdir([filepath '\\patches\\']);
    
    % display patches
    for i=1:nselected
        patchsize = 30;
        npatches = nneighvec(i);
        rstimg = zeros(patchsize,patchsize*npatches,3);
        rstimg = uint8(rstimg);
        for j=1:npatches
            
            patch = imresize(patchescollected{i,j},[patchsize,patchsize]);
            rstimg(1:end,patchsize*(j-1)+1:patchsize*j,1) = patch(:,:,1);
            rstimg(1:end,patchsize*(j-1)+1:patchsize*j,2) = patch(:,:,2);
            rstimg(1:end,patchsize*(j-1)+1:patchsize*j,3) = patch(:,:,3);
        end
        imwrite(rstimg,[filepath '\\patches\\' sprintf('patch_clique_%04d.png',i)]);
        fprintf('save %d patches %05d/%05d\n',npatches,i,nselected);
    end
end

save([filepath, '\features\patches.mat'],'patchescollected','featinfoall','-v7.3');