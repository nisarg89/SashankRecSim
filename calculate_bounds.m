function [m, lo, hi] = calculate_bounds(mat,dim,perc)
% Calculate the statistics of matrix mat across dimension dim. 
% The returned matrices have dimension dim cut out.
% perc is the confidence level out of 100.

s = size(mat);
s = s([1:dim-1 dim+1:length(s)]); % Remove dimension dim
if length(s) == 1
    s = [1 s];
end

% The use of reshape rather than squeeze prevents other singleton
% dimensions from being cut out. 
m = reshape(mean(mat,dim),s);
lo = reshape(prctile(mat,(100-perc),dim),s); 
hi = reshape(prctile(mat,perc,dim),s);
end