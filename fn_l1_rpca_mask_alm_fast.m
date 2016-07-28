% this function is written by Ricardo Carbal based on the following paper.
% Unifying Nuclear Norm and Bilinear Factorization Approaches for Low-rank Matrix Decomposition

function [M_est U_est V_est obj] = fn_l1_rpca_mask_alm_fast(M,W,Ureg,r,lambda1,U,V,maxIterIN, rho, scale)
%% Robust low-rank matrix approximation with missing data and outliers
% min |W.*(M-E)|_1 + lambda*|V|_*
% s.t., E = UV, U'*U = I
%
%Input:
%   M: m*n data matrix
%   W: m*n indicator matrix, with '1' means 'observed', and '0' 'missing'.
%   r: the rank of r
%   lambda: the weighting factor of the trace-norm regularization, 1e-3 in default.
%   rho: increasing ratio of the penalty parameter mu, usually 1.05.
%   maxInterIN: maximum iteration number of inner loop, usually 100.
%   signM: if M>= 0, then signM = 1, otherwise, signM = 0;
%Output:
%   M_est: m*n full matrix, such that M_est = U_est*V_est
%   U_est: m*r matrix
%   V_est: r*n matrix
%   L1_error: the L1-norm error of observed data only.

%% In-default parameters
GPU = 0;

[m n] = size(M); %matrix dimension
if nargin < 7
  maxIterIN = 5;
  rho = 1.05; % 1.005 works
end  
if nargin < 5
  U = randn(m,r);
  V = randn(n,r);
end
if nargin < 4
  disp('Please input the data matrix M, the indicator W and the rank r, and try again.');
end

maxIterOUT = 5000;
max_mu = 1e20;
mu = 1e-3;
M_norm = norm(M,'fro');
tol = 1e-9*M_norm;
%tol = 1e-10

cW = ones(size(W)) - W; %the complement of W.
display = 1; %display progress
%% Initializing optimization variables as zeros
E = randn(m,n);
Y = zeros(m,n); %lagrange multiplier


Y = M;
norm_two = svd(Y);
norm_two = norm_two(1);

mu = 1.25/norm_two;
norm_inf = norm( Y(:), inf) / lambda1;
dual_norm = max(norm_two, norm_inf);
Y = Y / dual_norm;


%% caching
lr1 = lambda1*eye(r);
lambda2 = lambda1*scale; % for visualhull or indicator matrix is used.
lr2 = lambda2*eye(r);

if GPU
    W = gpuArray(W);
    cW = gpuArray(cW);
    M = gpuArray(M);
    Ureg = gpuArray(Ureg);
    U = gpuArray(U);
    V = gpuArray(V);
    Y = gpuArray(Y);
    E = gpuArray(E);
    lr1 = gpuArray(lr1);
    lr2 = gpuArray(lr2);
end


%% Start main outer loop
iter_OUT = 0;
while iter_OUT < maxIterOUT
  iter_OUT = iter_OUT + 1;
  
  itr_IN = 0;
  obj_pre = 1e20;
  %start inner loop
  while itr_IN < maxIterIN
      
    %update U    
    tmp = mu*E + Y;
    %U = (tmp)*V/(lr1 + mu*(V'*V));
    U = ((tmp)*V + lambda2*Ureg)/(lr1 + mu*(V'*V) + lr2);
    U(:,2) = 1; % this is my trick used for albedo problem. Jaesik Park
    
    %update V
    V = (tmp)'*U/(lr1 + mu*(U'*U));
    
    %update E
    UV = U*V';
    temp1 = UV - Y/mu;
    
    % l1
    temp = M-temp1;
    El1 = max(0,temp - 1/mu) + min(0,temp + 1/mu);
    El1 = (M-El1);

    E = El1.*W + temp1.*cW;
    
    %evaluate current objective
    temp1 = sum(sum(W.*abs(M-E)));
    temp2 = norm(U,'fro')^2;
    temp3 = norm(V,'fro')^2;
    temp4 = sum(sum(Y.*(E-UV)));
    temp5 = norm(E-UV,'fro')^2;
    temp6 = norm(U-Ureg,'fro')^2;
    obj_cur = temp1 + lambda1/2*temp2 + temp3 + temp4 + mu/2*temp5 + lambda2/2*temp6;
        
    %check convergence of inner loop
    if abs(obj_cur - obj_pre) <= 1e-10*abs(obj_pre)
      break;
    else
      obj_pre = obj_cur;
      itr_IN = itr_IN + 1;
    end
  end
  
  leq = E - UV;
  stopC = norm(leq,'fro');
  fprintf('iter : %d\n',iter_OUT);
  if stopC<tol
    break;
  else
    %update lagrage multiplier
    Y = Y + mu*leq;
    %update penalty parameter
    mu = min(max_mu,mu*rho);
  end
end

%% Denormalization
U_est = U;
V_est = V;

M_est = U_est*V_est';
obj = sum(sum(W.*abs(M-E))) + lambda1/2*(norm(U,'fro') + norm(V,'fro'));


if GPU
    M_est = gather(M_est);
    U_est = gather(U_est);
    V_est = gather(V_est);
end

end
