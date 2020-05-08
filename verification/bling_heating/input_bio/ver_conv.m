% script to convert between grid for sea-ice verification experiments and
% grid for BLING verification experiments

% sea-ice verification experiments are 384 x 16
% BLING verification experiments are 128 x 64 

function out = ver_conv(old_name,new_name)

old_grid = binread8(old_name,384,16,12);
new_grid(1:128,1:64,1:12) = 0;

for i = 1:128
    i_lo = 3*i - 2;
    i_hi = 3*i;
    for j = 1:64
        jj = ceil(j/4);
        new_grid(i,j,:) = nanmean(old_grid(i_lo:i_hi,jj,:));
    end
end

binwrite(new_name,new_grid);

return

