function trajNormals = distribute_normals(normals_vertex, trajs, ptsIndices, trajStarts, trajLambdas)
nTraj = length(trajs);

trajNormals = cell(nTraj, 1);

for i = 1:nTraj
    lens = sqrt(sum(diff(trajs{i}).^2, 2));
    cumlens = [0; cumsum(lens)];
    
    sel = (ptsIndices(:, 1) == i);
    
    % collect data..
    starts = trajStarts(sel);
    lambdas = trajLambdas(sel);
    
    % curve parameter
    s = cumlens(starts) + lens(starts) .* (1 - lambdas); 
    
    % fit normals with curved parameters...
    trajNormals{i} = cubic_smooth(s, normals_vertex(sel, :), cumlens);
end;
