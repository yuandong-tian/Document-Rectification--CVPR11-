function trajs = trajs_scale(trajs, scale)
trajs = cellfun(@(x)(x*scale), trajs, 'UniformOutput', false);
