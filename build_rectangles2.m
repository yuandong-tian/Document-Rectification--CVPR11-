function [pts, rects, ptsIndices, trajStarts, trajLambdas] = build_rectangles2(trajs, coords, nCol)
nTraj = length(trajs);
% sample coords to build the mesh...

% Step 1: find min/max value of the coordinates..
minVal = Inf;
maxVal = -Inf;
for i = 1:nTraj
    minVal = min(minVal, coords{i}(1));
    maxVal = max(maxVal, coords{i}(end));    
end;
% do not touch the two boundaries..
knots = linspace(minVal, maxVal, nCol + 3);
knots = knots(2:end-1);

pts = zeros(nTraj, 2, nCol + 1);
trajStarts = zeros(nTraj, 1, nCol + 1);
trajLambdas = zeros(nTraj, 1, nCol + 1);

for i = 1:nCol + 1
    [pts(:, :, i), trajStarts(:, 1, i), trajLambdas(:, 1, i)] = find_pts_at_knot(trajs, coords, knots(i));   
end;

% then build rectangle from the pts...
rects = [];
for i = 1:nCol
    
    j = 1;
    while j <= nTraj && (pts(j, 1, i) < 0 || pts(j, 1, i + 1) < 0)
        j = j + 1;
    end;
    
    while j <= nTraj
        % if the four points are all valid, then build a rectangle out of that..
        nj = j + 1;
        while nj <= nTraj && (pts(nj, 1, i) < 0 || pts(nj, 1, i + 1) < 0)
            nj = nj + 1;
        end;
        
        if nj <= nTraj && nj == j + 1
            % order: left bottom -> right bottom -> right top -> left up..
            ind1 = sub2ind([nTraj, nCol + 1], nj, i);
            ind2 = sub2ind([nTraj, nCol + 1], nj, i + 1);
            ind3 = sub2ind([nTraj, nCol + 1], j, i + 1);
            ind4 = sub2ind([nTraj, nCol + 1], j, i);
            
            rects = [rects; [ind1, ind2, ind3, ind4]];
        end;
        j = nj;
    end;
end;

[x, y] = meshgrid(1:(nCol+1), 1:nTraj);
ptsIndices = [y(:), x(:)];
trajStarts = reshape(permute(trajStarts, [1, 3, 2]), [nTraj * (nCol + 1), 1]);
trajLambdas = reshape(permute(trajLambdas, [1, 3, 2]), [nTraj * (nCol + 1), 1]);
pts = reshape(permute(pts, [1, 3, 2]), [nTraj * (nCol + 1), 2]);

% remove all the invalid points..
valid_indices = unique(rects(:));

% 
pts = pts(valid_indices, :);
ptsIndices = ptsIndices(valid_indices, :);
trajStarts = trajStarts(valid_indices);
trajLambdas = trajLambdas(valid_indices);

lookup_table = zeros(nTraj * (nCol + 1), 1);
lookup_table(valid_indices) = 1:length(valid_indices);

rects = lookup_table(rects);


function [pts, starts, lambdas] = find_pts_at_knot(trajs, coords, coord_val)
nTraj = length(trajs);

pts = repmat(-1, nTraj, 2);
starts = zeros(nTraj, 1);
lambdas = zeros(nTraj, 1);

for i = 1:nTraj
    [ind_b, ind_e, lambda] = lambda_search(coords{i}, coord_val);
    if ind_b < ind_e
        % valid 
        pts(i, :) = (1 - lambda) * trajs{i}(ind_b, :) + lambda * trajs{i}(ind_e, :);
        starts(i) = ind_b;
        lambdas(i) = lambda;
    end;
end;
