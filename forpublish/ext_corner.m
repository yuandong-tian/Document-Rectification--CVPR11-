function [centers, gx, gy, corner] = ext_corner(img, harris_thresh)
% extract the corner, as well as the gradients
intScl = 1.5;
difScl = 0.7;
alpha = 0.04;
if ~exist('harris_thresh', 'var')
    harris_thresh = 1e-7;
end;

[corner, gx, gy] = cv_harris(img, intScl, difScl, alpha, harris_thresh);
corner(1:5, 1:5) = 0;
corner(1:5, end-4:end) = 0;
corner(end-4:end, 1:5) = 0;
corner(end-4:end, end-4:end) = 0;
% nonlocalmax suppression
[ys, xs] = find(imregionalmax(corner));
centers = [xs, ys];
