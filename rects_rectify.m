function [rectImg, rectImg_l, shading, centers, bWhitespace] = rects_rectify(pts3, rects, ptsIndices, pts, img, text_spacing, lowerfirst, options)
if ~exist('options', 'var')
    options = [];
end;
options = argutil_setdefaults(options, 'light', false);

% use the distance in pts3 to compute a rect image
% Step 1: compute the mean distances to determine scale...
nRect = size(rects, 1);

nTraj = max(ptsIndices(:, 1));
nCol = max(ptsIndices(:, 2));

hlens = cell(nCol, 1);
vlens = cell(nTraj, 1);
tableIndices = zeros(nTraj - 1, nCol - 1);

% rects:
%   4 --- 3
%   |     |
%   1 --- 2
for i = 1:nRect
    i1 = rects(i, 1);
    i2 = rects(i, 2);
    i3 = rects(i, 3);
    i4 = rects(i, 4);
    
    v1_i = ptsIndices(i4, 1); 
    v2_i = ptsIndices(i2, 1);
    h1_i = ptsIndices(i4, 2);
    h2_i = ptsIndices(i2, 2); 
    
    hlens{h1_i} = [hlens{h1_i}; i4, i3];
    hlens{h2_i} = [hlens{h2_i}; i2, i1];
    vlens{v1_i} = [vlens{v1_i}; i4, i1];
    vlens{v2_i} = [vlens{v2_i}; i2, i3];
    
    tableIndices(v1_i, h1_i) = i;
end;
% 
hlens = cellfun(@(x)(unique_edges_dists(x, pts3)), hlens, 'UniformOutput', false);
vlens = cellfun(@(x)(unique_edges_dists(x, pts3)), vlens, 'UniformOutput', false);

% optimize each delta x and delta y independently
deltaxs = cellfun(@(x)(mean(x)), hlens);
deltays = cellfun(@(x)(mean(x)), vlens);

% rescale ...
ratio = mean(deltays) / text_spacing;

deltaxs = deltaxs / ratio;
deltays = deltays / ratio;
% enforce the same height...
deltays = repmat(mean(deltays), [size(deltays), 1]);

% then rectify the image..
xcoords = round([0; cumsum(deltaxs)]) + 1;
ycoords = round([0; cumsum(deltays)]) + 1;

width = xcoords(end);
height = ycoords(end);

sel = repmat(false, height, width);
[X, Y] = meshgrid(1:width, 1:height);
mapx = zeros(height, width);
mapy = zeros(height, width);
normals = zeros(height, width, 3);

centers = zeros(nTraj-1, nCol-1, 2);
bWhitespace = repmat(false, nTraj-1, nCol-1);

for i = 1:nTraj-1
    yb = ycoords(i);
    ye = ycoords(i + 1);
    ygrid = yb:ye;
    
    for j = 1:nCol-1
        xb = xcoords(j);
        xe = xcoords(j + 1);
        xgrid = xb:xe;
        
        centers(i, j, :) = ([xb, yb] + [xe, ye]) / 2;
        
        index = tableIndices(i, j);
        if index == 0
            % no rectangle here..
            continue;
        end;
        
        if xor(mod(i, 2) == 0, lowerfirst)
            bWhitespace(i, j) = true;
        end;

        sel(:) = false;
        sel(ygrid, xgrid) = true;
        
        % estimate a perspective transform between the two...
        dstTest = estimate_perspective([xb, ye; xe, ye; xe, yb; xb, yb], pts(rects(index, :), :), [X(sel(:)), Y(sel(:))]);
        mapx(sel(:)) = dstTest(:, 1);
        mapy(sel(:)) = dstTest(:, 2);
        
        if options.light
            % normals are interpolated from the four points...
            lambda = (X(sel(:)) - xb) / (xe - xb);
            mu = (Y(sel(:)) - yb) / (ye - yb);
            % interpolation...
            n1 = options.normals(rects(index, 1), :);
            n2 = options.normals(rects(index, 2), :);
            n3 = options.normals(rects(index, 3), :);
            n4 = options.normals(rects(index, 4), :);
            
            thisNormal = zeros(sum(sel(:)), 3);
            for k = 1:3
                thisNormal(:, k) = (1 - lambda) .* ( (1 - mu) .* n4(k) + mu .* n1(k)) +  lambda .* ( (1 - mu) .* n3(k) + mu .* n2(k) );
            end;
            
            normals(ygrid, xgrid, :) = reshape(thisNormal, [ye - yb + 1, xe - xb + 1, 3]);
        end;
    end;
end;

centers = reshape(centers, [(nTraj-1) * (nCol-1), 2]);
bWhitespace = bWhitespace(:);

rectImg = reshape(interp2(img, mapx(:), mapy(:)), [height, width]);

if options.light
    % compute the shading...
    normals = reshape(normals, [width*height, 3]);
    normals = normalize_v(normals);
    
    % invoke the light model...
    shading = light_evaluate(options.light_model, [mapx(:), mapy(:)], normals);
    shading = reshape(shading, [height, width]);
    
%     linearimg = (log(rectImg) - 5.6914) / 0.4644;
%     rectImg  = exp(linearimg ./ (shading + options.ambient));
    
    rectImg_l = rectImg ./ (shading);
end;

function vals = unique_edges_dists(edges, pts3)
reversed = edges(:, 2) < edges(:, 1);
edges(reversed, :) = [edges(reversed, 2), edges(reversed, 1)];
edges = unique(edges, 'rows');
% then compute the distance for each edge..
vals = zeros(size(edges, 1), 1);
for i = 1:size(edges, 1)
    vals(i) = norm(pts3(edges(i, 1), :) - pts3(edges(i, 2), :));
end;