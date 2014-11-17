function trajs = trajs_remove_tails(trajs)
trajs = cellfun(@(x)(remove_tail(x)), trajs, 'UniformOutput', false);

function traj = remove_tail(traj)
nNode = size(traj, 1);
eps = 8;
% remove the heads and tails that are going back and forth...
dist_first = sqrt(sum((traj - repmat(traj(1, :), [nNode, 1])).^2, 2));
dist_last = sqrt(sum((traj - repmat(traj(end, :), [nNode, 1])).^2, 2));

index_first = find(dist_first < eps, 1, 'last');
index_last = find(dist_last < eps, 1, 'first');

traj = traj(index_first:index_last, :);

