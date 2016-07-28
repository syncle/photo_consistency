
function albedo = fn_init_albedo(pg,pc,O,W)

fprintf('fn_init_albedo\n');

npts = size(O,1);
% nimg = size(O,2);

b = zeros(npts,1);
for ptid=1:npts    
    vid_int = find(W(ptid,:)==1);    
    nvid_int = numel(vid_int);
    
    if nvid_int==0
        continue;
    end    
    
    ades = zeros(nvid_int,1);
    for iter = 1:nvid_int
        imgid = vid_int(iter);
        gg = pg(imgid);
        cc = pc(imgid);    
        oo = O(ptid,imgid);        
        ades(iter) = (oo/gg-cc);
    end
    ades_mid = median(ades);
    b(ptid) = ades_mid;
end
albedo = b;