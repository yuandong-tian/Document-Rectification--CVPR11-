function dists = dist_to_01(lambdas)
nLambda = length(lambdas);

region1 = lambdas >= 1;
region2 = lambdas <= 0;

dists = zeros(nLambda, 1);
dists(region1) = lambdas(region1) - 1;
dists(region2) = -lambdas(region2);

