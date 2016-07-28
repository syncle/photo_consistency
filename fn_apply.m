
function fn_apply(filepath,names,colorchannel)


load([filepath, '\estimation\', 'Estimation.mat']);
rstpath = [filepath '\results\'];
mkdir(rstpath);

nframes = size(names,1);

if nframes == 2
    styletransfer = 1;
    transferid = 2;
else
    styletransfer = 0;
    transferid = 2;
end


for i=1:nframes
    
    imgname = names{i};
    img = imread([filepath, '\input\', imgname]);
    
    figure(1);
    subplot(1,2,1); imshow(img); title('original image');
    
    if strcmp(colorchannel,'YCBCR')
        img = rgb2ycbcr(img);
    end
    
    img = im2double(img);
    for ch=1:3
        cc = const{ch}(i);
        gg = gamma{ch}(i);
        ii = img(:,:,ch);

        %%% prevent abrupt change
        if gg < 0.5 || gg > 3
            gg = 1;
        end
            
        %%% prevent abrupt change
        if cc < 0.3 || cc > 3
            cc = 1;
        end
        
        if styletransfer        
            %%% for style transfer
            ii = (ii.^(1/gg))/cc;
            cc2 = const{ch}(transferid);
            gg2 = gamma{ch}(transferid);
            ii = (ii*cc2).^gg2;            
            ii(ii > 1) = 1;
            ii(ii < 0) = 0;
            img(:,:,ch) = ii;
        else
            img(:,:,ch) = (ii.^(1/gg))/cc;            
        end
        
    end
    
    if strcmp(colorchannel,'YCBCR')
        img = ycbcr2rgb(img);
    end
    
    img = uint8(img*255);
    subplot(1,2,2); imshow(img); title('adjusted');
    
    if styletransfer   
        imwrite(img,[rstpath sprintf('rst_style%d_%05d.png',transferid,i-1)]);
    else
        imwrite(img,[rstpath sprintf('rst_%05d.png',i-1)]);
    end
end