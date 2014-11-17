function trajs3D = put_z_to_trajs(trajs, pts3, ptsIndices, trajStarts, trajLambdas)
nTraj = length(trajs);

trajs3D = cell(nTraj, 1);

for i = 1:nTraj
    lens = sqrt(sum(diff(trajs{i}).^2, 2));
    cumlens = [0; cumsum(lens)];
    
    sel = (ptsIndices(:, 1) == i);
    
    % collect data..
    starts = trajStarts(sel);
    lambdas = trajLambdas(sel);
    
    % curve parameter
    s = cumlens(starts) + lens(starts) .* (1 - lambdas); 
    
    % fit x/y/z with curved parameters...
%    trajs3D{i} = cubic_smooth(s, pts3(sel, :), cumlens);
    % interpolation...
    [lambdas, nodeIndices, inter_region] = traj_coord_sample(s, cumlens);
    trajs3D{i} = traj_interpolate(pts3(sel, :), lambdas, nodeIndices);
end;
