function [magSqr, binning] = im_binning(gx, gy, nBin)
% For normal gx and gy: 
%  (1,1)
%   --------------------------------------------------------------
%   | Image
%   |
%   |                        nBin/4 + 1
%   |                      ...     |
%   |                    3         |
%   |                 2            |
%   |                1 <---------- O --------->  nBin/2+1
%   |                              |              
%   |                              |           
%   |                              |       ...
%   |                       3*nBin/4 + 1

[m, n] = size(gx);

magSqr = gx.^2 + gy.^2;
% range: (-pi, pi)
ori = atan2(gy, gx);

edges = linspace(-pi, pi, nBin + 1);
edgesBoundary = (edges(1:end-1) + edges(2:end)) / 2;

binning = ones(m, n);
for i = 1:nBin-1
    binning = binning + (ori > edgesBoundary(i));
end; 
binning(ori > edgesBoundary(nBin)) = 1;

% edges = linspace(-pi, pi, nBin + 1);
% % 
% binning = ones(m, n);
% for i = 2:nBin
%     binning = binning + (ori > edges(i));
% end;

