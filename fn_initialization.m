
function [O,W,gamma,cons] = fn_initialization(O)

% initilize albedo, gamma, constants, indicator matrix
fprintf('fn_initialization\n');

nimg = size(O{1},2);
npts = size(O{1},1);

% keyboard;

gamma = cell(3,1);
cons = cell(3,1);
W = zeros(npts,nimg);
vid = cell(3,1);
for ch=1:3
    gamma{ch} = ones(nimg,1);   % real scale
    cons{ch} = zeros(nimg,1);     % log scale 1 goes to 0
    vid{ch} = find(O{ch} > 2/255);
end
vidintersect = intersect(intersect(vid{1},vid{2}),vid{3});
W(vidintersect) = 1;


% figure;
% for ch=1:3
%     subplot(1,3,ch);
%     hist(O{ch}(vid),100);
%     title(sprintf('channel %d',ch));
% end


% log scale image
for ch=1:3
%     o = O{ch}*255;
% keyboard;
    o = O{ch};
    O{ch}(vidintersect) = log(o(vidintersect));
end