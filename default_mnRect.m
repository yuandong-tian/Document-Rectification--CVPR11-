function [mRectImg, nRectImg, text_space] = default_mnRect(trajs)
nTraj = length(trajs);
% compute default value of mRectImg and nRectImg
spacing = zeros(nTraj-1, 1);
text_len = zeros(nTraj, 1);
for i = 1:nTraj-1
    spacing(i) = traj_shortest_dist(trajs{i+1}, trajs{i});
    text_len(i) = traj_length(trajs{i});
end;
text_len(nTraj) = traj_length(trajs{nTraj});
text_space = round(mean(spacing) * 1.5);

mRectImg = ceil((nTraj + 1) * text_space);
nRectImg = ceil(max(text_len));

function minDist = traj_shortest_dist(traj1, traj2)
[dx, dy] = ml_dist2(traj1, traj2);
dists = dx.^2 + dy.^2;
minDist = sqrt(min(dists(:)));

function len = traj_length(traj)
nNode = size(traj, 1);
len = 0;
for i = 1:nNode-1
    len = len + sqrt( sum( (traj(i, :) - traj(i+1, :)).^2 ) );
end;