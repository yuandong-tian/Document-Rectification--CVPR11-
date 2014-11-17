function zis = my_interp2(xgrids, ygrids, zs, xs, ys)
nPoint = length(xs);
nDim = size(zs, 3);

zis = zeros(nDim, nPoint);
for i = 1:nPoint
    [xind_b, xind_e, alpha_x] = lambda_search(xgrids, xs(i));
    [yind_b, yind_e, alpha_y] = lambda_search(ygrids, ys(i));
    
    zis(:, i) = (1 - alpha_x) * ( (1 - alpha_y) * zs(xind_b, yind_b, :) + alpha_y * zs(xind_b, yind_e, :)) + ...
                 alpha_x * ( (1 - alpha_y) * zs(xind_e, yind_b, :) + alpha_y * zs(xind_e, yind_e, :));
end;