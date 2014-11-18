function [patchXs, patchYs] = im_partition(img, w, h, ratio)
if length(img) == 2
    m = img(1);
    n = img(2);
else
    [m, n] = size(img);
end;
if ~exist('ratio', 'var')
    ratio = 0.5;
end;

if abs(ratio) < 1e-8
    % dense sampling
    stepx = 1;
    stepy = 1;
else
    stepx = floor(w * ratio);
    stepy = floor(h * ratio);
end;

patchXs = 1:stepx:(n-w+1);
patchYs = 1:stepy:(m-h+1);
% 
if n - w + 1 - patchXs(end) > stepx / 2
    patchXs = [patchXs, n - w + 1];
end;
if m - h + 1 - patchYs(end) > stepy / 2
    patchYs = [patchYs, m - h + 1];
end;