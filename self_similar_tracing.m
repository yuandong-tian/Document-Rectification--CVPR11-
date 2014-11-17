function trajectories = self_similar_tracing(img, seeds, dir, options)
if ~exist('options', 'var')
    options = [];
end;
options = argutil_setdefaults(options, 'patchSize', 21, 'nAngle', 10, 'step', 3, 'nHistory', 15, 'lambda', 0.01, 'nPoint', 30, 'accessRegion', [], 'func', @ms_l1);

% tracing from initp along dir
optionsCrop.check = true;
optionsCrop.tolerate = false;
optionsCrop.expand = false;

angles = linspace(-pi, pi, options.nAngle + 1);
angles = angles(1:end-1)';
moveVecs = round([cos(angles), sin(angles)] * options.step);

angleDist = angle_dist(angles, dir);

gate1 = angleDist >= pi / 2;
gate2 = (angleDist < pi / 2) .* angleDist;
regularizer = options.lambda * options.patchSize^2 * gate2;
regularizer(gate1) = Inf;

nSeed = size(seeds, 1);
trajectories = cell(nSeed, 1);

t0 = tic;
for i = 1:nSeed
    if mod(i, 10) == 0
        t = toc(t0);
        fprintf(1, 'deal with seed #%d/%d, time spent = %f\n', i, nSeed, t);
        t0 = tic;
    end;
    bbox = bb_fromCenterSize(seeds(i, :), options.patchSize);
    patches = im_crop(img, bbox, optionsCrop);

    if isempty(patches)
        continue;
    end;

    p = seeds(i, :);
    for iter = 1:options.nPoint
        trajectories{i} = [trajectories{i}; p];
        % find next patch...
        [p, nextpatch, bInf] = trace_next(img, p, moveVecs, patches, regularizer, options);
    
        if isempty(nextpatch) || bInf || (~isempty(options.accessRegion) && ~options.accessRegion(p(2), p(1)))
            break;
        end;
    
        patches = cat(3, patches, nextpatch);
        if size(patches, 3) > options.nHistory
            patches = patches(:, :, 2:end);
        end;
    end;
end;
