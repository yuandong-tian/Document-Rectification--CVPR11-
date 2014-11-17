function rectImg = lines_rectify5(img, trajs, coords, options)
if ~exist('options', 'var')
    options = [];
end;

[mRectImg, nRectImg, text_space] = default_mnRect(trajs);

options = argutil_setdefaults(options, 'aspectRatio', nRectImg / mRectImg, 'light', []);
% print the result...
% imshow(img);
% hold on;
% for i = 1:nTraj
%     nSample = 5;
%     sampleInds = round(linspace(1, size(trajs{i}, 1), nSample));
%     for j = 1:nSample
%         traj_ind = sampleInds(j);
%         text(trajs{i}(traj_ind, 1), trajs{i}(traj_ind, 2), num2str(coords{i}(traj_ind)), 'FontSize', 18, 'BackgroundColor', [.7, .9, .7]);
%     end;
% end;
% hold off;

% once we get the coordinates, we can interpolate...
[minX, maxX] = find_boundary(coords);
xseq = linspace(minX, maxX, nRectImg);

height = nRectImg / options.aspectRatio;
lineSpacing = round(height / (length(trajs) - 1));

w = length(xseq);
h = (length(trajs) - 1)*lineSpacing + 1;

points = repmat(nan, [w, 2, h]);
if ~isempty(options.light)
    normals = repmat(nan, [w, 3, h]);
end;

for i = 1:length(trajs)
    base = (i - 1) * lineSpacing + 1;
    [lambdas, nodeIndices, inter_region] = traj_coord_sample(coords{i}, xseq);
    points(inter_region, :, base) = traj_interpolate(trajs{i}, lambdas(inter_region), nodeIndices(inter_region));
    
    if ~isempty(options.light)
        normals(inter_region, :, base) = traj_interpolate(options.trajNormals{i}, lambdas(inter_region), nodeIndices(inter_region));
    end;
    
    if i > 1
        for j = 1:lineSpacing-1
            lambda = j / lineSpacing;
            points(:, :, base - j) = lambda * points(:, :, base - lineSpacing) + (1 - lambda) * points(:, :, base);
            
            if ~isempty(options.light)
                normals(:, :, base - j) = lambda * normals(:, :, base - lineSpacing) + (1 - lambda) * normals(:, :, base);
            end;
        end;
    end;
end;

% then interpolate....
points = permute(points, [3 1 2]);
x = points(:, :, 1);
y = points(:, :, 2);

valid = ~isnan(x) & ~isnan(y);

rectImg = zeros(h, w);
% finally, interpolation!
rectImg(valid) = interp2(img, x(valid), y(valid));

if ~isempty(options.light)
    normals = permute(normals, [3, 1, 2]);
    normals = normalize_v(normals);
    normals = reshape(normals, [w*h, 3]);
    
    shading = zeros(h, w);
    
    shading(valid) = normals(valid, :) * options.light(:);
    
%     linearimg = zeros(h, w);
%     linearimg(valid) = (log(rectImg(valid)) - 5.6914) / 0.4644;
%   rectImg(valid)  = exp(linearimg(valid) ./ (shading(valid) + options.ambient));
    
    rectImg(valid)  = rectImg(valid) ./ (shading(valid) + options.ambient);

end;

function [minX, maxX] = find_boundary(coords)
nTraj = length(coords);

minX = Inf;
maxX = -Inf;
for i = 1:nTraj
    minX = min(minX, min(coords{i}));
    maxX = max(maxX, max(coords{i}));    
end;
