function newTrajAll = local_refine_textline3(img, upperbound, lowerbound, trajAll, trajValid, startwithLower)
nTraj = length(trajAll);
%options.Display = 'iter';
isLowers = xor(startwithLower, mod(1:nTraj, 2) == 0);

% now dir is just vertical
dir = [0, 1];
% 
%lambda = .1;
%lambda = 1e3;
lambda = 1e1;
invalid_margin = 3;

newTrajAll = cell(nTraj, 1);

for i = 1:nTraj
    fprintf(1, 'Deal with #Traj = %d\n', i);   

    traj = trajAll{i};
    [dummy, tangents] = smooth(traj);
    nNode = size(traj, 1);
    % assume the traj is from top to bottom...
    % compute the search range by draw a vertical line from each vertex of the traj 
    if i == 1
        uppertraj = upperbound;
    else
        uppertraj = trajAll{i-1};
    end;
    if i == nTraj
        lowertraj = lowerbound;
    else
        lowertraj = trajAll{i+1};
    end;
    
    ptsUpper = traj_intersect(uppertraj, traj, repmat(dir, nNode, 1), 1);
    ptsLower = traj_intersect(lowertraj, traj, repmat(dir, nNode, 1), 1);
    
    ys = round([ptsUpper(:, 2), ptsLower(:, 2)]);
    ysInvalid = (ys(:, 1) >= ys(:, 2));
    % make invalid part valid, by adding/substracting margins..
    meanInvalid = (ys(ysInvalid, 1) + ys(ysInvalid, 2)) / 2;
    ys(ysInvalid, 1) = meanInvalid - invalid_margin;
    ys(ysInvalid, 2) = meanInvalid + invalid_margin;
    
    ysSel = cell(nNode, 1);
    ys_dists = cell(nNode, 1);
    pts = [];
    % compute the local responses...
    for j = 1:nNode
        % individually optimizes each node on the trajectory...fix the
        % x-coordinates, and optimize over y-coordinates..
        x = traj(j, 1);
        if ~trajValid{i}(j)
            ys_dists{j} = zeros(ys(j, 2) - ys(j, 1) + 1, 1);
            continue;
        end;
        
        [dists, uniformMeasure] = compute_dists(img, x, ys(j, 1), ys(j, 2), tangents(j), isLowers(i));
        % find local mins...
        ysSel{j} = [false; dists(2:end-1) < dists(1:end-2) & dists(2:end-1) < dists(3:end); false];
%         if ~isempty(localminIndices)
%             % pick those local mins...
%             ysSel{j} = ys(j, 1) + localminIndices - 1;
%             % then you find the one that is closest to traj(j, 2)...
%             [minVal, minInd] = min(abs(ysSel{j} - traj(j, 2)));
%             traj(j, 2) = ysSel{j}(minInd);
%         end;
        ys_dists{j} = dists;
        % get rid of the local maxs if it is uniform..
        pts = [pts; repmat(traj(j, 1), [sum(ysSel{j}), 1]), ys(j, 1) + find(ysSel{j}) - 1];
    end;
    
    % solution 1: try dp...unfortunately, the solution is pretty bumpy...
    [funcVal, traj] = compute_optimal_trajectory_dp(traj(:, 1), ys, ys_dists, traj, lambda);
    fprintf(1, 'DP done, optimal funcVal = %d\n', funcVal);
    % solution 2: just fit a line 
    % then smooth it using kernel...
    % traj = kernel_smooth(pts, 200, 2);
    % solution 3: RANSAC!
    %traj = ransac_smoothing(pts);
    
    if false
        imshow(img); hold on;
        plot(pts(:, 1), pts(:, 2), 'r+', 'LineWidth', 2);
        plot(traj(:, 1), traj(:, 2), 'b-')
    end;
   
    % connect ~trajValid{i} part..
    % find the offset...
    firstInd = find(~trajValid{i}, 1);
    offset = traj(firstInd, :) - trajAll{i}(firstInd, :);
    
    traj(~trajValid{i}, :) = trajAll{i}(~trajValid{i}, :) + repmat(offset, [sum(~trajValid{i}), 1]);
    newTrajAll{i} = traj;
end;

function traj = ransac_smoothing(pts)
nPts = size(pts, 1);
nSample = floor(nPts / 2);
sigma = 60;
lambda = 5;

% estimate variance and get the thres...
thisTraj = kernel_smooth(pts, sigma, lambda);
thres = sqrt(mean( (thisTraj(:, 2) - pts(:, 2)).^2 ));

nIter = 300;
bestInliers = [];

for i = 1:nIter
    % random sample nSample pts..
    p = randperm(nPts);
    [thisTraj, model] = kernel_smooth(pts(p(1:nSample), :), sigma, lambda);
    % compute the meanError for training...
    %sigma = sqrt(mean( (thisTraj(:, 2) - pts(p(1:nSample), 2)).^2 ));
    
    % then predict the rest of the points...
    pred = kernel_evaluate(model, pts(:, 1));
    % compute the error and threshold it..
    errors = abs(pred(:, 2) - pts(:, 2));
    % compute inliers
    inliers = errors < thres;
   
    if sum(bestInliers) < sum(inliers)
        bestInliers = inliers;
        fprintf(1, 'find better inlier set, size = %d\n', sum(bestInliers));
    end;
end;

% finally fit a model...
traj = kernel_smooth(pts(bestInliers, :), sigma, lambda);

function [traj, tangents, c] = smooth(traj)
% fit a model y = ax^3 + bx^2 + cx + d
nPoint = size(traj, 1);

x = traj(:, 1);
X = [x.^3, x.^2, x, ones(nPoint, 1)];
%X = [x.^4, x.^3, x.^2, x, ones(nPoint, 1)];

c = X \ traj(:, 2);

% smoothed
traj(:, 2) = X * c;
tangents = [3*x.^2, 2*x, ones(nPoint, 1)] * c(1:end-1);

function [dists, uniformMeasure] = compute_dists(img, x, ymin, ymax, tangent, isLower)
patchSide = floor( (ymax - ymin + 1) / 2);
patchSize = 2*patchSide + 1;

[X, Y] = meshgrid(-patchSide:patchSide, -patchSide:patchSide);
% compute the mask
mask = 2 * (X * tangent - Y > 0) - 1;

optionsCrop.check = true;
optionsCrop.tolerate = false;
optionsCrop.expand = false;

dists = zeros(ymax - ymin + 1, 1);
uniformMeasure = zeros(ymax - ymin + 1, 1);
bbox = bb_fromCenterSize(round([x, ymin]), patchSize);

for y = ymin:ymax
    patch = im_crop(img, bbox, optionsCrop);
    i = y - ymin + 1;
    
    if isempty(patch)
        dists(i) = nan;
        uniformMeasure(i) = 0;
    else
        dists(i) = mean(mask(:) .* patch(:));
        uniformMeasure(i) = std(patch(:));
    end;
    bbox([2, 4]) = bbox([2, 4]) + 1;
end;

if ~isLower 
    dists = -dists;
end;
dists(isnan(dists)) = Inf;

function [funcVal, traj] = compute_optimal_trajectory_dp(x, ys, ys_dists, ref_traj, lambda)
% The goal is to link the local minimal points so as to give a smooth solutions..
% the objective function...
% n variables (n = length(x))
% domain: 
% i-th variable: y_i : starting from ys(i, 1) to ys(i, 2)
% min J(y_1, ..., y_n) = \sum_{i=1}^n phi_i(y_i) + lambda * \sum_{i=1}^{n-1} phi_{i,i+1} (y_i, y_{i+1})
% where 
% phi_i(y_i) is to measure the badness of y_i in ys_dists{i}
% phi_{i, i+1}(y_i, y_{i+1}) is the L2 distance between (x_i, y_i) and (x_{i+1}, y_{i+1})
% phi_{i, i+1}(y_i, y_{i+1}) is the cos angle between vector = (x_i+1, y_i+1) - (x_i, y_i) and ref_traj(:, i+1) - ref_traj(:, i)

% find the largest lens
lens = ys(:, 2) - ys(:, 1) + 1;
K = max(lens);

% n variables..
n = length(x);

ref_diffs = diff(ref_traj);
% normalize..
ref_diffs = ref_diffs ./ repmat(sum(ref_diffs.^2, 2), [1, 2]);

% compute distances...
dists = cell(n-1, 1);
for i = 1:n-1
    dists{i} = zeros(lens(i), lens(i+1));
    xdistSqr = (x(i) - x(i+1)).^2;
    ydiff = ys(i, 1) - ys(i+1, 1);
    for j = 1:lens(i)
        for k = 1:lens(i+1)
            %dists{i}(j, k) = sqrt(xdistSqr + (ydiff + j - k).^2) * lambda;
            v = [x(i+1) - x(i), ys(i+1, 1) - ys(i, 1) + k - j];
            dists{i}(j, k) = (1 - sum(ref_diffs(i, :) .* v) / norm(v)) * lambda;
        end;
    end;
end;

bestJs = repmat(Inf, K, n);
bestJsChoose = zeros(K, n-1);
% for variable 1
bestJs(:, 1) = [ys_dists{1}; repmat(Inf, K - lens(1), 1)];

for i = 2:n
    % for variable y_i
    nextBestJ = repmat(Inf, lens(i), 1);
    for j = 1:lens(i)
        bestGivenI = zeros(lens(i-1), 1);
        for k = 1:lens(i-1)
            bestGivenI(k) = bestJs(k, i-1) + dists{i-1}(k, j);
        end;
        [nextBestJ(j), bestJsChoose(j, i-1)] = min(bestGivenI);
    end;
    % add the current potential
    bestJs(1:lens(i), i) = nextBestJ + ys_dists{i};
end;

% then find the optimal solution and backtrace the solution...
sol = zeros(n, 1);
[funcVal, sol(end)] = min(bestJs(:, end));
for i = n-1:-1:1
    sol(i) = bestJsChoose(sol(i+1), i);
end;

traj = [x, sol + ys(:, 1) - 1];