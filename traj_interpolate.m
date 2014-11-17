function interpolated = traj_interpolate(traj, lambdas, nodeIndices)
n = length(lambdas);
nDim = size(traj, 2);

interpolated = repmat(nan, n, nDim);
valid = ~isnan(lambdas);

lambdas_dup = repmat(lambdas(valid), [1, nDim]);
interpolated(valid, :) = (1 - lambdas_dup) .* traj(nodeIndices(valid), :) + lambdas_dup .* traj(nodeIndices(valid) + 1, :);