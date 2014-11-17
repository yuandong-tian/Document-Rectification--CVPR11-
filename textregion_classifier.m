function binaryMap = textregion_classifier(img, options)
if ~exist('options', 'var')
    options = [];
end;
options = argutil_setdefaults(options, 'filterSize', 5, 'sigma', 2);

% heuristics...
[corners, gx, gy] = ext_corner(img);
mag = gx.^2 + gy.^2;

%gf = fspecial('gaussian', 21, 5);
gf = fspecial('gaussian', options.filterSize, options.sigma);
magFiltered = imfilter(mag, gf);

% cvpr uses 1e-3
threshold = 1e-3;
binaryMap = (magFiltered > threshold);