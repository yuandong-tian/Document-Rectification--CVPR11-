function [poses, orth_dirs] = traj_sample(traj, step, nPoint)
% sample the trajectory with step...
nNode = size(traj, 1);
if nNode < 2
    poses = [];
    return;
end;

dirs = diff(traj); % row difference..
lens = sqrt(sum(dirs.^2, 2));
dirs = dirs ./ repmat(lens, [1, 2]);

index = 1;
lambda = 0;

if exist('nPoint', 'var')
    poses = zeros(nPoint, 2);
    orth_dirs = zeros(nPoint, 2);
    for k = 1:nPoint
        poses(k, :) = traj(index, :) + dirs(index, :) * lambda;
        orth_dirs(k, :) = [-dirs(index, 2), dirs(index, 1)]; % orth.
    
        lambda = lambda + step;
        while index <= nNode - 1 && lambda > lens(index)
            lambda = lambda - lens(index);
            index = index + 1;
        end;
    end;
else
    poses = [];
    orth_dirs = [];
    while index <= nNode - 1
        poses = [poses; traj(index, :) + dirs(index, :) * lambda];
        orth_dirs = [orth_dirs; -dirs(index, 2), dirs(index, 1)]; % orth.
    
        lambda = lambda + step;
        while index <= nNode - 1 && lambda > lens(index)
            lambda = lambda - lens(index);
            index = index + 1;
        end;
    end;
end;
