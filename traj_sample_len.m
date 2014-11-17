function poses = traj_sample_len(traj, nPoint)
% sample the trajectory with step...
nNode = size(traj, 1);
if nNode < 2
    poses = [];
    return;
end;

dirs = diff(traj); % row difference..
lens = sqrt(sum(dirs.^2, 2));
dirs = dirs ./ repmat(lens, [1, 2]);
% for possible out of bound sake..
dirs = [dirs; dirs(end, :)];

index = 1;
lambda = 0;

poses = zeros(nPoint, 2);
step = sum(lens) / (nPoint - 1);
for k = 1:nPoint
    poses(k, :) = traj(index, :) + dirs(index, :) * lambda;

    lambda = lambda + step;
    while index <= nNode - 1 && lambda > lens(index)
        lambda = lambda - lens(index);
        index = index + 1;
    end;
end;
