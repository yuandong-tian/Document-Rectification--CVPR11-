function [cornernessIm, Ix, Iy] = cv_harris(Im, intScl, difScl, alpha, harris_thres)
if ~exist('harris_thres', 'var')
    harris_thres = 1e-7;
end;

% first get Ix and Iy
g = m_gauss(difScl);
gd = -m_gaussDerivative(difScl);
% filter~~
Ix = conv2(g, gd, Im, 'same');
Iy = conv2(gd, g, Im, 'same');
% again using another gaussian kernel to filter Ix^2, Iy^2, IxIy
gInt = m_gauss(intScl);
Ix2 = conv2(gInt, gInt, Ix.^2, 'same');
Iy2 = conv2(gInt, gInt, Iy.^2, 'same');
Ixy = conv2(gInt, gInt, Ix.*Iy, 'same');
% find harris
tr = Ix2 + Iy2;
deter = Ix2.*Iy2 - Ixy.^2;
cornernessIm = deter - alpha * tr.^2;
cornernessIm(cornernessIm < harris_thres) = 0;

Ix(1, :) = 0;
Ix(end, :) = 0;
Iy(1, :) = 0;
Iy(end, :) = 0;

Ix(:, 1) = 0;
Ix(:, end) = 0;
Iy(:, 1) = 0;
Iy(:, end) = 0;