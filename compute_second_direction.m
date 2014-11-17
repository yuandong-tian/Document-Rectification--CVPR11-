function [funcVal, dirs, mask0, mask, patchXs, patchYs] = compute_second_direction(img, nSide)
nBin = 64;
lambda = 7;
if ~exist('nSide', 'var')
    nSide = 100;
end;

[corners, gx, gy] = ext_corner(img);
[magSqr, binning] = im_binning(gx, gy, 2*nBin);
binning(binning > nBin) = binning(binning > nBin) - nBin;
mag = sqrt(magSqr);

% initial guess
histogram = get_histogram(mag, binning, nBin);
[maxVal, initGuess] = max(histogram);
initGuess = 6;

% partition the image
ratio = 0.5;
[patchXs, patchYs] = im_partition(img, nSide, nSide, ratio);
nXs = length(patchXs);
nYs = length(patchYs);

fprintf(1, 'nXs = %d, nYs = %d, finding local histogram...\n', nXs, nYs);
% find local histogram (overlapping!)
hists = zeros(nBin, nXs, nYs);
for i = 1:nXs
    xsel = patchXs(i):patchXs(i)+nSide-1;
    for j = 1:nYs
        ysel = patchYs(j):patchYs(j)+nSide-1;
        hists(:, i, j) = get_histogram(mag(ysel, xsel), binning(ysel, xsel), nBin);
    end;
end;

%what if we just find the maxIndex for each hist..
% dirs = repmat(initGuess, nXs, nYs);
% for i = 1:nXs
%     for j = 1:nYs
%         [maxVal, dirs(i, j)] = max(hists(:, i, j));
%     end;
% end;
% funcVal = 0;
% mask0 = [];
% mask = [];
% return;

% the variable to be optimized. 
dirs = repmat(initGuess, nXs, nYs);
[funcVal, mask0] = compute_objective(dirs, mag, binning, nBin, nSide, patchXs, patchYs, lambda);
fprintf(1, 'initial funcVal = %d...\n', funcVal);

% find intersecting histogram...
fprintf(1, 'finding intersecting histograms...\n');
hists_intersect_labels = [];
hists_intersect = [];
for i1 = 1:nXs
    xsel1 = patchXs(i1):patchXs(i1)+nSide-1;
    for i2 = 1:nXs
        xsel2 = patchXs(i2):patchXs(i2)+nSide-1;
        
        xsel = intersect(xsel1, xsel2);
        if isempty(xsel)
            continue;
        end;

        for j1 = 1:nYs
            ysel1 = patchYs(j1):patchYs(j1)+nSide-1;
            for j2 = 1:nYs
                ysel2 = patchYs(j2):patchYs(j2)+nSide-1;
                
                ysel = intersect(ysel1, ysel2);
                if (i1 == i2 && j1 == j2) || isempty(ysel)
                    continue;
                end;
                
                hists_intersect_labels = [hists_intersect_labels; i1, j1, i2, j2];
                hist = get_histogram(mag(ysel, xsel), binning(ysel, xsel), nBin);
                hists_intersect = [hists_intersect, hist];
            end;
        end;
    end;
end;

fprintf(1, 'start optimization...\n');
% Step 3, coordinate descent!
iter = 1;
maxIter = 100;
funcVal = Inf;
while iter < maxIter
    % compute the objective function...
    prevFuncVal = funcVal;
    [funcVal, mask] = compute_objective(dirs, mag, binning, nBin, nSide, patchXs, patchYs, lambda);
    fprintf(1, '#iter = %d, funcVal = %d...\n', iter, funcVal);
    iter = iter + 1;
    
    if abs(prevFuncVal - funcVal) < 1e-8 * abs(funcVal)
        break;
    end;
        
    for i = 1:nXs
        for j = 1:nYs
%             % find intersecting histograms...
            histogram_indices = find(hists_intersect_labels(:, 1) == i & hists_intersect_labels(:, 2) == j);
            nNeighbor = length(histogram_indices);

            histograms = zeros(nBin, nNeighbor + 1);
            dirs_this = zeros(nNeighbor + 1, 1);

            for k = 1:nNeighbor
                histIndex = histogram_indices(k);
                histograms(:, k) = hists_intersect(:, histIndex);
                intersect_i = hists_intersect_labels(histIndex, 3);
                intersect_j = hists_intersect_labels(histIndex, 4);
                dirs_this(k) = dirs(intersect_i, intersect_j);
            end;
            % finally put the histogram of this region..
            histograms(:, end) = hists(:, i, j);
            % optimize this block...run for all possible nBin
            inc_values = zeros(nBin, 1);
            for candidate_dir = 1:nBin
                dirs_this(end) = candidate_dir;
                inc_values(candidate_dir) = compute_objective_ij(histograms, dirs_this, lambda);
            end;
            % find the best one..
            [minValue, min_dir] = min(inc_values);
            dirs(i, j) = min_dir;

% simple method..way too slow...
%             funcVals = zeros(nBin, 1);
%             for candidate_dir = 1:nBin
%                 dirs(i, j) = candidate_dir;
%                 [funcVals(candidate_dir)] = compute_objective(dirs, mag, binning, nBin, nSide, patchXs, patchYs, lambda);
%             end;
%             [minValue, min_dir] = min(funcVals);
%             dirs(i, j) = min_dir;

%             histogram_indices = (hists_intersect_labels(:, 1) == i & hists_intersect_labels(:, 2) == j);
%             neighbors = hists_intersect_labels(histogram_indices, 3:4);
% 
%             funcVals = zeros(nBin, 1);
%             for candidate_dir = 1:nBin
%                 dirs(i, j) = candidate_dir;
%                 [funcVals(candidate_dir)] = compute_objective_local(dirs, mag, binning, nBin, nSide, patchXs, patchYs, lambda, i, j, neighbors);
%             end;
%             [minValue, min_dir] = min(funcVals);
%             dirs(i, j) = min_dir;
        end;
    end;
end;
 

function histogram = get_histogram(mag, binning, nBin)
histogram = zeros(nBin, 1);
for i = 1:nBin
    histogram(i) = sum(mag(binning == i));
end;

function dist = orient_distance(ind, inds)
nBin = length(inds);
    
dist1 = abs(ind - inds);
dist2 = abs(ind - inds + nBin);
dist3 = abs(ind - inds - nBin);

dist = min(min(dist1, dist2), dist3);

function funcVal = compute_objective_ij(histograms, dirs, lambda)
[nBin, nHist] = size(histograms);
dists = zeros(nBin, 1);

for i = 1:nHist
    distance = orient_distance(dirs(i), 1:nBin)';
    dists = dists + (distance - lambda) .* histograms(:, i);
end;
funcVal = sum(dists(dists < 0));

function [funcVal, selectedPixels] = compute_objective(dirs, mag, binning, nBin, nSide, patchXs, patchYs, lambda)
[m, n] = size(mag);

nXs = length(patchXs);
nYs = length(patchYs);
dists = zeros(m, n);
for i = 1:nXs
    xsel = patchXs(i):patchXs(i)+nSide-1;
    for j = 1:nYs
        ysel = patchYs(j):patchYs(j)+nSide-1;
        binPatch = binning(ysel, xsel);
        
        distance = orient_distance(dirs(i, j), 1:nBin)';
        dists(ysel, xsel) = dists(ysel, xsel) + (distance(binPatch) - lambda) .* mag(ysel, xsel);
    end;
end;
selectedPixels = (dists < 0);
funcVal = sum(dists(dists < 0));

function [funcVal, selectedPixels] = compute_objective_local(dirs, mag, binning, nBin, nSide, patchXs, patchYs, lambda, i, j, neighbors)
xsel = patchXs(i):patchXs(i)+nSide-1;
ysel = patchYs(j):patchYs(j)+nSide-1;

binPatch = binning(ysel, xsel);
distance = orient_distance(dirs(i, j), 1:nBin)';
dists = (distance(binPatch) - lambda) .* mag(ysel, xsel);

% put neighbor regions...
nNeighbor = size(neighbors, 1);
for k = 1:nNeighbor
    nI = neighbors(k, 1);
    nJ = neighbors(k, 2);
    
    xsel_neighbor = patchXs(nI):patchXs(nI)+nSide-1;
    ysel_neighbor = patchYs(nJ):patchYs(nJ)+nSide-1;
    
    xsel_n = intersect(xsel, xsel_neighbor);
    ysel_n = intersect(ysel, ysel_neighbor);
    
    xsel_n_r = xsel_n - xsel(1) + 1;
    ysel_n_r = ysel_n - ysel(1) + 1;
    
    binPatch = binning(ysel_n, xsel_n);
    distance = orient_distance(dirs(nI, nJ), 1:nBin)';

    dists(ysel_n_r, xsel_n_r) = dists(ysel_n_r, xsel_n_r) + (distance(binPatch) - lambda) .* mag(ysel_n, xsel_n);
end;

selectedPixels = (dists < 0);
funcVal = sum(dists(dists < 0));
