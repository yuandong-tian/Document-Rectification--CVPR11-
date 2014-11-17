function dstTest = estimate_perspective(src, dst, srcTest)
% estimate a perspective transform
nPoint = size(src, 1);

xy1 = [src, ones(nPoint, 1)];

A = [xy1,                zeros(nPoint, 3)     , -src(:, 1:2) .* repmat(dst(:, 1), [1, 2]);...
     zeros(nPoint, 3),   xy1                  , -src(:, 1:2) .* repmat(dst(:, 2), [1, 2]);];
 
b = [dst(:, 1); dst(:, 2)];

coeffs = A \ b;
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);
f = coeffs(6);
g = coeffs(7);
h = coeffs(8);

dstTest = zeros(size(srcTest));

denom = g * srcTest(:, 1) + h * srcTest(:, 2) + 1;

dstTest(:, 1) = (a * srcTest(:, 1) + b * srcTest(:, 2) + c) ./ denom;
dstTest(:, 2) = (d * srcTest(:, 1) + e * srcTest(:, 2) + f) ./ denom;