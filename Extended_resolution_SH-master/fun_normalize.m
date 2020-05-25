%% normalize the 2d matrix in the scale of 0-1
function [nor] = fun_normalize(input)
% [m,n]=size(in_phase);
tmp=input;
min_v=min(tmp(:));
tmp=tmp-min_v;
max_v=max(tmp(:));
nor=tmp./max_v;
end