
function fn_estimation(filepath,scale)

load([filepath, '\estimation\observation.mat']);

[O,W,~,~] = fn_initialization(O);
lambda = 1/sqrt(min(size(O{1},1),size(O{1},2))); % parameter
rho = 1.05; % DO NOT CHANGE!!!

npts = size(O{1},1);
nimg = size(O{1},2);

albedo = cell(3,1);
const = cell(3,1);
gamma = cell(3,1);

O_low = cell(3,1);

for ch=1:3

    fprintf('channel %d\n',ch);

    a_init = fn_init_albedo(ones(nimg,1),zeros(nimg,1),O{ch},W);
    g_init = ones(1,nimg);%+randn(1,nimg)/20;
    c_init = zeros(1,nimg);%+randn(1,nimg)/20;

    A = [a_init, ones(npts,1)];
    GC = [g_init; c_init.*g_init];

    tic;
    [O_l,A_est,GC_est,obj] = fn_l1_rpca_mask_alm_fast(O{ch},W,A,2,lambda,A,GC',1,rho,scale);
    toc;

    GC_est = GC_est';

    O_low{ch} = O_l;

    albedo{ch} = exp(A_est(:,1));
    gamma{ch} = GC_est(1,:);
    const{ch} = exp(GC_est(2,:)./GC_est(1,:));

end

save([filepath '\estimation\Estimation.mat'],'O_low','albedo','const','gamma');
