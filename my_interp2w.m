function zis = my_interp2w(xgrids, ygrids, zs, ws, xs, ys)
nPoint = length(xs);
nDim = size(zs, 3);

zis = zeros(nDim, nPoint);
for i = 1:nPoint
    [xind_b, xind_e, alpha_x] = lambda_search(xgrids, xs(i));
    [yind_b, yind_e, alpha_y] = lambda_search(ygrids, ys(i));
    
    zbb = zs(xind_b, yind_b, :);
    zbe = zs(xind_b, yind_e, :);
    zeb = zs(xind_e, yind_b, :);
    zee = zs(xind_e, yind_e, :);
    
    wbb = ws(xind_b, yind_b);
    wbe = ws(xind_b, yind_e);
    web = ws(xind_e, yind_b);
    wee = ws(xind_e, yind_e);
    
    zis(:, i) = (1 - alpha_x) * ( (1 - alpha_y) * zbb*wbb + alpha_y * zbe*wbe) + alpha_x * ( (1 - alpha_y) * zeb*web + alpha_y * zee*wee);
    weight = (1 - alpha_x) * ( (1 - alpha_y) * wbb + alpha_y * wbe) + alpha_x * ( (1 - alpha_y) * web + alpha_y * wee);
             
    zis(:, i) = zis(:, i) / weight;
end;