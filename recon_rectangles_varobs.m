function pts3 = recon_rectangles_varobs(pts, rects, options)
if ~exist('options', 'var')
    options = [];
end;
options = argutil_setdefaults(options, 'lambda', [], 'z_constraint', true, 'scale', 1);

stdxy = sqrt(mean(pts.^2, 1)) / options.scale;
% normalize pts...
pts(:, 1) = pts(:, 1) / stdxy(1);
pts(:, 2) = pts(:, 2) / stdxy(2);

xmin = min(pts(:, 1));
ymin = min(pts(:, 2));
xmax = max(pts(:, 1));
ymax = max(pts(:, 2));

meanspan = max(abs([xmin, xmax, ymin, ymax]));
%lambda = 1e-1 / meanspan^2;
if isempty(options.lambda)
    % cvpr: lambda = 1 / meanspan^2;
    lambda = 1 / meanspan^2;
    %lambda = 1e-3 / meanspan^2;
    %lambda = 10 / meanspan^2;
    %lambda = 1e-1 / meanspan^2;
else
    lambda = options.lambda;
end;

n = size(pts, 1);
m = size(rects, 1);

pts = [pts, ones(n, 1)];
polarity = [-1, 1, -1, 1];

if options.z_constraint
    nDim = 3;
else
    nDim = 2;
end;

% m * nDim constraints....
A = sparse(nDim*m, 3*n);
% coplanar terms...
for i = 1:m
    % rect i:    rects(i, 1) --- rects(i, 2)
    %                  |             |
    %            rects(i, 4) --- rects(i, 3)
    for j = 1:nDim
        constraint_index = nDim*(i-1) + j;
        A(constraint_index, 3*(rects(i, :)-1) + j) = polarity;
    end;
end;

B = sparse(2*n, 3*n);
% data-terms...
for i = 1:n
    % X - x_i Z...
    B(2*i-1, 3*i-2) = 1;
    B(2*i-1, 3*i) = -pts(i, 1);
    % Y - y_i Z...    
    B(2*i, 3*i-1) = 1;
    B(2*i, 3*i) = -pts(i, 2);
end;

% solve the homogenous equation Az = 0
%     [U, D, V] = svd(A + sqrt(lambda) * B);
%     [minSingularValue, minIndex] = min(diag(D));
M = A'*A + lambda * B'*B;

[V, D] = eigs(M, 1, 'SM');
[minEigValue, minIndex] = min(diag(D));
sol = V(:, minIndex);
%    fprintf(1, 'minSingularValue = %d\n', minSingularValue);
fprintf(1, 'minEigenValue = %d\n', minEigValue);

pts3 = reshape(sol', [3, n])';

% 
if sum(pts3(:, 3)) > 0
    pts3 = -pts3;
end;

% normalze it back
pts3(:, 1) = pts3(:, 1) * stdxy(1);
pts3(:, 2) = pts3(:, 2) * stdxy(2);
