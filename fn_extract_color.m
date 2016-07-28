
function fn_extract_color(filepath,names,augmentation,augratio,patchsize)

nframes = size(names,1);

load([filepath, '\features\patches.mat']);
load([filepath, '\features\selected.mat']);

mkdir([filepath, '\estimation\']);

ncollections = size(patchescollected,1);

if augmentation    
    if augratio > patchsize^2
        augratio = patchsize^2;
    end
    augid = round(rand(augratio,1)*(patchsize^2-1))+1;
    
    O1 = zeros(ncollections*augratio,nframes);
    O2 = zeros(ncollections*augratio,nframes);
    O3 = zeros(ncollections*augratio,nframes);
else
    O1 = zeros(ncollections,nframes);
    O2 = zeros(ncollections,nframes);
    O3 = zeros(ncollections,nframes);
end

f = fspecial('gaussian',[5,5]);

cnt = 1;
for i=1:ncollections
    for j=1:nneighvec(i)
        
        imgid = featinfoall(cnt,1);
        colid = featinfoall(cnt,3);
        cnt = cnt + 1;
        patch = patchescollected{i,j};
        patch = imresize(patch,[patchsize,patchsize]);
                
        if augmentation
            
            patchr = patch(:,:,1);
            patchg = patch(:,:,2);
            patchb = patch(:,:,3);
            val1 = double(patchr(augid))/255;
            val2 = double(patchg(augid))/255;
            val3 = double(patchb(augid))/255;
            
            stid = (colid-1)*augratio+1;
            edid = colid*augratio;
            
            O1(stid:edid,imgid) = val1;
            O2(stid:edid,imgid) = val2;
            O3(stid:edid,imgid) = val3;
            
        else

            mean1 = double(median(median(patch(:,:,1))))/255;
            mean2 = double(median(median(patch(:,:,2))))/255;
            mean3 = double(median(median(patch(:,:,3))))/255;
            
            O1(colid,imgid) = mean1;
            O2(colid,imgid) = mean2;
            O3(colid,imgid) = mean3;
        end
        
    end
end

O = cell(3,1);
O{1} = O1;
O{2} = O2;
O{3} = O3;

save([filepath, '\estimation\observation.mat'],'O');