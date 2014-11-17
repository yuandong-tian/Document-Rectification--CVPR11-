function [imgD, scale, meanMags] = textreg_scale(img)
nScale = 15;
scaleFactor = 0.8;

imgLayers = cell(nScale, 1);
imgLayers{1} = img;

meanMags = zeros(nScale, 1);
for i = 1:nScale
    fprintf(1, 'scale = %d\n', i);
    % compute the mean edge density...
    [corners, gx, gy] = ext_corner(imgLayers{i});
    mag = (gx.^2 + gy.^2);
    meanMags(i) = mean(mag(:));
    if i < nScale
        imgLayers{i + 1} = imresize(imgLayers{i}, scaleFactor);
    end;
end;

% find the first peak from the left..
localmax = ( meanMags(2:end-1) > meanMags(1:end-2) ) & ( meanMags(2:end-1) > meanMags(3:end) );
maxIndex = find(localmax, 1) + 1;
%[maxVal, maxIndex] = max(meanMags);
% plus 4, is the factor ideal for our approach (-_-||)
if ~isempty(maxIndex)
    scale = scaleFactor ^ (maxIndex);
else
    scale = scaleFactor ^ 3;
end;

imgD = imresize(img, scale);