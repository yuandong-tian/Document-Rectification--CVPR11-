function [normals, pixels, bWhiteSpace, pixel_locations] = compute_shading(img, pts3, rects, pts2, ptsIndices, lowerfirst)
% compute the surface normal...
nRect = size(rects, 1);

normals = zeros(nRect, 3);
pixels = zeros(nRect, 1);
bWhiteSpace = repmat(false, nRect, 1);
pixel_locations = zeros(nRect, 2);

bboxes = zeros(nRect, 4);

for i = 1:nRect
    i1 = rects(i, 1);
    i2 = rects(i, 2);
    i3 = rects(i, 3);
    i4 = rects(i, 4);
    
    % check white space...
    trajInd = ptsIndices(i3, 1);
    if xor(mod(trajInd, 2) == 0, lowerfirst)
        bWhiteSpace(i) = true;
    end;
    
    v_h = (pts3(i2, :) - pts3(i1, :) + pts3(i3, :) - pts3(i4, :)) / 2;
    v_v = (pts3(i4, :) - pts3(i1, :) + pts3(i3, :) - pts3(i2, :)) / 2;
    
    normals(i, :) = cross(v_h, v_v);
    
    % get bounding box and pick the median value...
    % 
    v2d = pts2(rects(i, :), :);
    mins = round(min(v2d, [], 1));
    maxs = round(max(v2d, [], 1));
    
    % shrink the min/max a little bit...
    theSize = maxs - mins + 1;
    margins = theSize / 3;
    
    bboxes(i, :) = [mins(1), mins(2), maxs(1), maxs(2)] + [margins(1), margins(2), -margins(1), -margins(2)];
    
    patch = img(mins(2):maxs(2), mins(1):maxs(1));
    pixels(i) = median(patch(:));
    pixel_locations(i, :) = mean(v2d, 1);
end;
% normalize all the normals
normals = normalize_v(normals);
% 
imshow(img);
hold on; 
bb_show(bboxes(bWhiteSpace, :));
hold off;