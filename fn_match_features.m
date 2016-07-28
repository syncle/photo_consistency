
function fn_match_features(filepath, names)

load([filepath, '\features\sift_total.mat']);

run('toolbox/vl_setup');

nframes = size(names,1);

M = cell(nframes,nframes);
F = cell(nframes,nframes);

visualizematch = 0;

nmatches = 0;
for i=1:nframes
    for j=i+1:nframes

        fprintf('Feat. Matching: %05d/%05d... ',i,j);
        
        imgnamei = names{i};
        imgnamej = names{j};
        
        Si = load([filepath, '\features\sift_' imgnamei '.mat']);
        Sj = load([filepath, '\features\sift_' imgnamej '.mat']);
        
        %%%%%%%%%%%%%%%%%%%%%
        % bi-directional matching
        fprintf('%d->%d',i,j);
        %[matches1, scores1] = vl_ubcmatch(Si.d, Sj.d, 1.8);
        [matches1, scores1] = vl_ubcmatch(Si.d, Sj.d);
        fprintf('(%d) ',size(matches1,2));
        
        fprintf('%d->%d',j,i);
        %[matches2, scores2] = vl_ubcmatch(Sj.d, Si.d, 1.8);
        [matches2, scores2] = vl_ubcmatch(Sj.d, Si.d);
        fprintf('(%d) ',size(matches2,2));
        
        % keyboard;
                
        [~,mid1,mid2] = intersect(matches1(1,:),matches2(2,:));
        
        if numel(mid1) == 0
            fprintf('no match!\n');
            continue;
        end
        
        matches = matches1(:,mid1);
        scores = (scores1(mid1)+scores2(mid2))/2;
        %%%%%%%%%%%%%%%%%%%%%
        
        mi = matches(1,:);
        mj = matches(2,:);
        s = scores;
        n = numel(mi);
        
        fprintf('%05d matched\n',n);
        
        % this stage is for preventing multiple matching pairs
        umi = unique(mi);
        umj = unique(mj);
        
        nmi = numel(mi);
        nmj = numel(mj);
        numi = numel(umi);
        numj = numel(umj);
        
        if (numi == nmi) && (numj == nmj)
            
            nmatches = nmatches + numel(s);
            fi = Si.f(:,mi);
            fj = Sj.f(:,mj);
            di = Si.d(:,mi);
            dj = Sj.d(:,mj);
            M{i,j} = [mi;mj;s];
            F{i,j} = [fi;fj];  
          
        else
            
            % note this is not a square matrix
            S = sparse(mi,mj,s,nfeat(i),nfeat(j));
            
            for p=1:nfeat(i)
                if nnz(S(p,:))>1
                    Ss = full(S(p,:));
                    [val,id] = max(Ss);
                    S(p,:) = 0;
                    S(p,id) = val;
                end
            end
            
            for p=1:nfeat(j)
                if nnz(S(:,p))>1
                    Ss = full(S(:,p));
                    [val,id] = max(Ss);
                    S(:,p) = 0;
                    S(id,p) = val;
                end
            end
            
            [mi,mj,s] = find(S~=0);
            mi = mi';
            mj = mj';
            s = s';
            
            nmatches = nmatches + numel(s);
            fi = Si.f(:,mi);
            fj = Sj.f(:,mj);
            M{i,j} = [mi;mj;s];
            F{i,j} = [fi;fj];
            
        end
        
        
        if visualizematch
            
            % for debugging
            imgi = imread([filepath imgnamei]);
            imgj = imread([filepath imgnamej]);
            patchesi = fn_extract_patches(imgi, fi(1,:), fi(2,:), fi(3,:)*5, fi(4,:));
            patchesj = fn_extract_patches(imgj, fj(1,:), fj(2,:), fj(3,:)*5, fj(4,:));
            foldername = sprintf('debug\\%02d_%02d\\',i,j);
            mkdir(foldername);
            
            for k=1:numel(mi)
                patchesi{k} = imresize(patchesi{k},[50,50]);
                imwrite(patchesi{k},[foldername sprintf('%02d_%02d_%05d.png',i,k,mi(k))]);
            end
            for k=1:numel(mj)
                patchesj{k} = imresize(patchesj{k},[50,50]);
                imwrite(patchesj{k},[foldername sprintf('%02d_%02d_%05d.png',j,k,mj(k))]);
            end
            
            % visualize match
            imgi = imread([filepath imgnamei]);
            imgj = imread([filepath imgnamej]);
            
            figure(1); imshow(imgi); hold on;
            for k=1:numel(mi)
                plot(fi(1,k),fi(2,k),'.','markersize',10);
                text(fi(1,k),fi(2,k),sprintf('%02d',k));
            end
            hold off;
            
            figure(2); imshow(imgj); hold on;
            for k=1:numel(mj)
                plot(fj(1,k),fj(2,k),'.','markersize',10);
                text(fj(1,k),fj(2,k),sprintf('%02d',k));
            end
            hold off;
            pause
            
        end
        
    end
end
save([filepath, '\features\match.mat'],'M','F','nmatches');