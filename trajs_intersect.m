function [lambdas, poses, bIntersect, trajsNodeIndices, trajsLambdas] = trajs_intersect(p1, p2, trajs)
nTraj = size(trajs, 1);

eps = 1e-1;

lambdas = zeros(nTraj, 1);
poses = zeros(nTraj, 2);
trajsNodeIndices = zeros(nTraj, 1);
trajsLambdas = zeros(nTraj, 1);
bIntersect = false(nTraj, 1);

for j = 1:nTraj
    nNode = size(trajs{j}, 1);
    if nNode < 2
        continue;
    end;
    
    ps = zeros(nNode-1, 2);
    lambda1s = zeros(nNode-1, 1);
    lambda2s = zeros(nNode-1, 1);
    for i = 1:nNode-1
        %fprintf(1, 'traj node = %d/%d\n', i, nNode-1);
        % two line intersection...
        [ps(i, :), lambda1s(i), lambda2s(i)] = line_intersect(p1, p2, trajs{j}(i, :), trajs{j}(i+1, :));
    end;
    [minDist, minIndex] = min(dist_to_01(lambda2s));
    
    poses(j, :) = ps(minIndex, :);
    trajsNodeIndices(j) = minIndex;
    trajsLambdas(j) = lambda2s(minIndex);
    lambdas(j) = lambda1s(minIndex);
    bIntersect(j) = (minDist < eps);
end;
