function [meanTrajLen, crossRange] = compute_range_traj3(trajs3D)
nTraj = length(trajs3D);

trajLens = zeros(nTraj, 1);
for i = 1:nTraj
    trajLens(i) = sum(sqrt(sum(diff(trajs3D{i}).^2, 2)));
end;
meanTrajLen = mean(trajLens);

% find the distance across the lines..
crossRange = 0.0;
for i = 1:nTraj-1
    crossRange = crossRange + dist_trajs(trajs3D{i}, trajs3D{i+1});
end;

function minDist = dist_trajs(traj1, traj2)
nNode1 = size(traj1, 1);
nNode2 = size(traj2, 1);

minDist = Inf;
for i = 1:nNode1-1
    for j = 1:nNode2-1
        minDist = min(minDist, dist_line_seg(traj1(i, :), traj1(i+1, :), traj2(j, :), traj2(j+1, :)));
    end;
end;

function [minDist, sol] = dist_line_seg(p1b, p1e, p2b, p2e)
% find minimal distance between two line segments..
v1 = p1e - p1b;
v2 = p2e - p2b;

delta = p2b - p1b;

a = sum(v1 .* v1);
b = -sum(v2 .* v1);
c = sum(v2 .* v2);

d1 = sum(delta .* v1);
d2 = sum(delta .* v2);

sol = [a, b; b, c] \ [d1; d2];
sol = max(min(sol, 1), 0);

minDist = norm(delta + v2 * sol(2) - v1 * sol(1));

