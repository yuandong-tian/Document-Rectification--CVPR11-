function light_model = light_train(xs, normals, pixels)
% train a local model...
% pixel(x) = pho * (n(x) .* (l + light(x)) + A)
% while light(x) is some function...

% ---------------------------------------
% light model 0
% light(x) = l0
% ---------------------------------------
% n = size(xs, 1);
% M = [normals, ones(n, 1)];
% coeffs = M \ pixels;
% rho = norm(coeffs(1:3));
% light_model.ambient = coeffs(end) / rho;
% light_model.l0 = coeffs(1:3) / rho;

% ---------------------------------------
% light model 1: linear...
% light(x) = l0 + lx * x(1) + ly * x(2)
% ---------------------------------------
% n = size(xs, 1);
% 
% M = [normals, repmat(xs(:, 1), [1, 3]) .* normals, repmat(xs(:, 2), [1, 3]) .* normals, ones(n, 1)];
% coeffs = M \ pixels;
% 
% rho = norm(coeffs(1:3));
% light_model.ambient = coeffs(end) / rho;
% light_model.l0 = coeffs(1:3) / rho;
% light_model.lx = coeffs(4:6) / rho;
% light_model.ly = coeffs(7:9) / rho;

% ---------------------------------------
% light model 2: rbf.....
% light(x) = l0 + \sum_i l_i rbf(x_i, x)
% ---------------------------------------
n = size(xs, 1);
sigma = 200;
lambda = .1;
nTrain = 30;

% pick some nodes...
[dx, dy] = ms_dist2(xs, xs);
distsSqr = dx.^2 + dy.^2;

train_sel = pick_scatter(distsSqr, nTrain);
rbf = exp(-distsSqr(:, train_sel) / 2 / sigma.^2);

rn1 = repmat(normals(:, 1), [1, nTrain]) .* rbf;
rn2 = repmat(normals(:, 2), [1, nTrain]) .* rbf;
rn3 = repmat(normals(:, 3), [1, nTrain]) .* rbf;

M = [normals, rn1, rn2, rn3, ones(n, 1)];
coeffs = inv(M'*M + diag([0; 0; 0; repmat(lambda, 3*nTrain, 1); 0])) * M' * pixels;

rho = norm(coeffs(1:3));
light_model.ambient = coeffs(end) / rho;

ls = reshape(coeffs(4:end-1), [nTrain, 3]) / rho;
light_model.l0 = coeffs(1:3) / rho;
light_model.ls = ls;
light_model.xs = xs(train_sel, :);
light_model.sigma = sigma;

% ---------------------------------------
% light model 3: rbf on just pixel values.......
% light(x) = x0 + \sum_i a_i rbf(x_i, x)
% ---------------------------------------
% n = size(xs, 1);
% sigma = 100;
% lambda = .1;
% [dx, dy] = ms_dist2(xs, xs);
% distsSqr = dx.^2 + dy.^2;
% rbf = exp(-distsSqr / 2 / sigma.^2);
% 
% M = [rbf, ones(n, 1)];
% coeffs = inv(M'*M + diag([repmat(lambda, n, 1); 0])) * M' * pixels;
% 
% light_model.ambient = coeffs(end);
% 
% as = coeffs(1:end-1);
% light_model.as = as;
% light_model.xs = xs;
% light_model.sigma = sigma;

%     brightness = (log(r.pixels(r.bWhiteSpace)) - 5.6914) / 0.4644;
%     light_w = [r.normals_rect(r.bWhiteSpace, :), ones(sum(r.bWhiteSpace), 1)] \ brightness;
