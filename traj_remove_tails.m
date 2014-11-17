function trajs = traj_remove_tails(trajs)
% remove the repetitive patterns...
eps = 1e-1;
for i = 1:length(trajs)
    [dx, dy] = ms_dist2(trajs{i}, trajs{i});
    dists = dx.^2 + dy.^2 < eps;
    % remove the points that have zero distances to other points...
    retained = (sum(dists, 1) == 1);
    trajs{i}(~retained, :) = [];
end;
