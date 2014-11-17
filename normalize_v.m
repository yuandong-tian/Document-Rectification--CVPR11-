function v = normalize_v(v)
nWay = length(size(v));
nDim = size(v, nWay);
v = v ./ repmat(sqrt(sum(v.^2, nWay)), [ones(1, nWay-1), nDim]);