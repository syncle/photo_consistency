
function patches = fn_extract_patches(img, x, y, s, t)

img = im2double(img);

h = size(img,1);
w = size(img,2);

nfeat = numel(x);
x = round(x);
y = round(y);
x(x<1) = 1;
x(x>w) = w;
y(y<1) = 1;
y(y>h) = h;

s = round(s);

imgch = cell(3,1);
for ch=1:3
    imgch{ch} = img(:,:,ch);
end

patches = cell(nfeat,1);

for iter=1:nfeat

    xx = x(iter);
    yy = y(iter);
    ss = s(iter);
    tt = t(iter);
    
    patchsize = ss*2+1;
    
    [xg,yg] = meshgrid(-ss:ss,-ss:ss);
    R = [cos(tt) -sin(tt);...
        sin(tt) cos(tt)];
    xygrot = R*[xg(:)'; yg(:)'];
    xygrot(1,:) = xygrot(1,:) + xx;
    xygrot(2,:) = xygrot(2,:) + yy;
    
    xr = xygrot(1,:)';
    yr = xygrot(2,:)';
    xf = floor(xr);
    yf = floor(yr);
    xp = xr-xf;
    yp = yr-yf;
    
    patch = zeros(patchsize,patchsize,3);    
    
%     % add condition    
%     if nnz(xf < 1) + nnz(xf > w-1) + nnz(yf < 1) + nnz(yf > h-1) ~= 0
%         patches{iter} = uint8(patch*255);
%         continue;
%     end

    vid = find(xf >= 1 & xf <= w-1 & yf >= 1 & yf <= h-1);
    xf = xf(vid);
    yf = yf(vid);
    xp = xp(vid);
    yp = yp(vid);
    
    ind1 = sub2ind([h,w],yf,xf);
    ind2 = sub2ind([h,w],yf,xf+1);
    ind3 = sub2ind([h,w],yf+1,xf);
    ind4 = sub2ind([h,w],yf+1,xf+1);
    
    for ch=1:3
        ivec = (1-yp).*(xp.*imgch{ch}(ind2)+(1-xp).*imgch{ch}(ind1))+...
                   (yp).*(xp.*imgch{ch}(ind4)+(1-xp).*imgch{ch}(ind3));
        temp = zeros(patchsize,patchsize);
        temp(vid) = ivec;
        patch(:,:,ch) = temp;
    end
    
%     figure(1); imshow(patch);
    
    patches{iter} = uint8(patch*255);

end