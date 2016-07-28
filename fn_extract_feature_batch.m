
function fn_extract_feature_batch(filepath,names)

run('toolbox/vl_setup');

nframes = size(names,1);

mkdir([filepath, '\features\']);

singlescale = 1;
scale = 2; 

if singlescale
    scale = 1;
end

remove_repetitive = 0;
remove_boundary = 0;
region_scale = 0.05; % todo: can we automatically detect?

if remove_boundary == 0
    region_scale = 0; % todo: can we automatically detect?
end


% batch SIFT feature extraction
nfeat = zeros(nframes,1);
for k=1:nframes
       
    imgname = names{k};
    img = imread([filepath, '\input\', imgname]);
	h = size(img,1);
    w = size(img,2);

    img = imresize(img,scale);            % trick for extracting less features
    img = single(rgb2gray(img));
    
    if singlescale
        [f,d] = vl_sift(img,'PeakThresh',1,'EdgeThresh',30);
    else
        [f,d] = vl_sift(img);
    end
    
    if remove_repetitive
        [~,idx,~] = unique(f(1,:)*h+f(2,:));    % remove repetatible features
        fprintf('reject repetitive features %d->%d\n',size(f,2),numel(idx));
        f = f(:,idx);
        d = d(:,idx);
    end
    
    f(1:3,:) = f(1:3,:)/scale;
    
    vid = find(f(1,:) > w*region_scale & f(1,:) < w*(1-region_scale) ...
            & f(2,:) > h*region_scale & f(2,:) < h*(1-region_scale));
    fprintf('reject boundary features %d->%d\n',size(f,2),numel(vid));    
    f = f(:,vid);
    d = d(:,vid);
    
    save([filepath, '\features\sift_' imgname '.mat'],'f','d');
    fprintf('Feat. Extraction : %05d/%05d (%05d features)\n',k,nframes,numel(vid));
    
    nfeat(k) = size(f,2);
end

nfeatcum = [0;cumsum(nfeat)];
nfeattot = nfeatcum(nframes+1);
save([filepath, '\features\sift_total.mat'],'nfeat','nfeatcum','nfeattot');