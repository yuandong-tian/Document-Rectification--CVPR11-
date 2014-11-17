function [poses, orth_dirs, trajsNodeIndices, trajsLambdas] = traj_intersect(traj, line_refs, line_dirs, text_spacing)
nNode = size(traj, 1);
dirs = zeros(nNode-1, 2);
lens = zeros(nNode-1, 1);
% compute the length and unit direction
for i = 1:nNode-1
    diff = traj(i + 1, :) - traj(i, :);
    lens(i) = sqrt(sum(diff.^2));
    dirs(i, :) = diff / lens(i);
end;

% intersect the trajectory with lines 
nLine = size(line_refs, 1);
lineNode1 = line_refs + line_dirs * text_spacing;
lineNode2 = line_refs - line_dirs * text_spacing;

poses = zeros(nLine, 2);
orth_dirs = zeros(nLine, 2);
trajsNodeIndices = zeros(nLine, 1);
trajsLambdas = zeros(nLine, 1);

for j = 1:nLine
    ps = zeros(nNode-1, 2);
    lambda2s = zeros(nNode-1, 1);
    for i = 1:nNode-1
        %fprintf(1, 'traj node = %d/%d\n', i, nNode-1);
        % two line intersection...
        [ps(i, :), dummy, lambda2s(i)] = line_intersect(lineNode1(j, :), lineNode2(j, :), traj(i, :), traj(i+1, :));
    end;
    [minDist, minIndex] = min(dist_to_01(lambda2s));
    
    poses(j, :) = ps(minIndex, :);
    trajsNodeIndices(j) = minIndex;
    trajsLambdas(j) = lambda2s(minIndex);
    
    orth_dirs(j, :) = [-dirs(minIndex, 2), dirs(minIndex, 1)]; % orth.
end;
