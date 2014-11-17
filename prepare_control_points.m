function [indexMap, pts, ptsGrads, ptsAngles] = prepare_control_points(thisImg, patchSide)
[~, gx, gy] = ext_corner(thisImg);
mags = sqrt(gx.^2 + gy.^2);
% threshold the gradient...
accessRegion = textregion_classifier(thisImg, struct('filterSize', 15, 'sigma', 5));
indices = find(mags > 0.05 & accessRegion);

[y, x] = ind2sub(size(mags), indices);
pts = [x, y];
ptsGrads = [gx(indices), gy(indices)];
%vis_dotOnImg(thisImg, pts);

% indexing these points...
indexMap = zeros(size(mags));
indexMap(indices) = 1:length(indices);

% compute ptsAngle using text flow...
thetas = linspace(-pi/2, pi/2, 30+1);
thetas = thetas(1:end-1);
profiles = compute_profiles(thisImg, pts, patchSide, thetas);
energy = squeeze(sum(profiles.^2, 1));
% Step 2: find the maximum as initial guess.....
[~, bestThetas] = max(energy, [], 1);
% ptsAngles = repmat([dir - pi/8, dir + pi/8], [size(pts, 1), 1]);
ptsAngles = thetas(bestThetas)';
ptsAngles = [ptsAngles - pi/32, ptsAngles + pi/32];
