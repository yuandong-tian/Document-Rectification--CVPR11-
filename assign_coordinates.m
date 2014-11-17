function coords = assign_coordinates(trajs, trajs3D, sampleSkewXs, sampleSkewYs, skewDirs)
nTraj = length(trajs);

% if size(trajs{1}, 2) == 3
%     z0 = trajs{1}(1, 3);
% else
%     z0 = 1;
% end;

% start with the first line. 
% the x-coordinates should be the geodesic distance along the line
%     the x-coordinates should be aligned for different lines using
%     skewness direction.
% the y-coordinates should be "on which textline you are on"...

coords = cell(nTraj, 1);
% set coordinates to the first line...

lens = compute_lens(trajs, trajs3D, 1);

% The following code assigns each node of the trajectory a coordinate...
coords{1} = [0; cumsum(lens)];
for i = 2:nTraj
    % from each node of trajs{i}, shoot a line to intersect trajs{i-1}, and
    % retrieve its x coordinates by interpolation...
    % if the line doesn't intersect, then compute the x-coordinates from
    % other points...
    angles = my_interp2(sampleSkewXs, sampleSkewYs, skewDirs, trajs{i}(:, 1), trajs{i}(:, 2))';
    
    % intersecting index = j     =>    intersect at line segment [j, j + 1] with lambda 
    [poses, orth_dirs, trajsNodeIndices, trajsLambdas] = traj_intersect(trajs{i-1}, trajs{i}, [cos(angles), sin(angles)], 1);
    % compute the coordinates
    nNode_this = size(trajs{i}, 1);
    coords{i} = zeros(nNode_this, 1);
    isSolved = repmat(false, nNode_this, 1);
    
    for j = 1:nNode_this
        nodeInd_prev = trajsNodeIndices(j);
        lambda_prev = trajsLambdas(j);
        
        if lambda_prev >= 0 && lambda_prev <= 1
            % the line indeed intersects a point on trajs{i-1}
            coords{i}(j) = (1 - lambda_prev) * coords{i-1}(nodeInd_prev) + lambda_prev * coords{i-1}(nodeInd_prev + 1);
            isSolved(j) = true;
        end;
    end;
    
    lens = compute_lens(trajs, trajs3D, i);
    % for all the unsolved coords, find the closest solved coordinates and compute the distance...
    unsolved = find(~isSolved)';
    solved = find(isSolved)';
    dists = ml_sqrDist(unsolved, solved);
    [dummy, minSolvedIndices] = min(dists, [], 2);
    
    for j = 1:length(unsolved)
        index = unsolved(j);
        solved_index = solved(minSolvedIndices(j));
        if index > solved_index
            coords{i}(index) = coords{i}(solved_index) + sum(lens(solved_index:index-1));
        else
            coords{i}(index) = coords{i}(solved_index) - sum(lens(index:solved_index-1));
        end;
    end;
end;

function lens = compute_lens(trajs, trajs3D, i)
if isempty(trajs3D)
    dirs = diff(trajs{i}); % row difference..
    lens = sqrt(sum(dirs.^2, 2));
else
    dirs = diff(trajs3D{i}); % row difference..
    lens = sqrt(sum(dirs.^2, 2));
end;

% nDim = size(traj, 2);
% if nDim == 3
%     % do the discount...
%     zs = (traj(1:end-1, 3) + traj(2:end, 3)) / 2;
%     lens = lens .* zs / z0;
% end;

