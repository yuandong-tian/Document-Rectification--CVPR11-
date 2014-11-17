function vis_vertical(patch, dirs, patchXs, patchYs, nSide, options)
if ~exist('options', 'var')
    options = [];
end;
[m, n] = size(patch);
options = argutil_setdefaults(options, 'computeAccessRegion', false, 'bbox', [1, 1, n, m]);

if options.computeAccessRegion
    accessRegion = textregion_classifier(patch, struct('filterSize', 25, 'sigma', 10));
else
    accessRegion = repmat(true, size(patch));
end;

% show the angle
len = 10;

imshow(patch);
axis([options.bbox(1), options.bbox(3), options.bbox(2), options.bbox(4)]);
hold on;
for i = 1:length(patchXs)
    for j = 1:length(patchYs)
        %p = [patchXs(i) + patchXs(i + 1), patchYs(j) + patchYs(j + 1)] / 2;
        p = [patchXs(i) + nSide / 2, patchYs(j) + nSide / 2];
        
        if accessRegion(p(2), p(1))
            % draw a line...
            skewAngle = (dirs(i, j) - 1) / 64 * pi;
            skewAngle = skewAngle + pi / 2;
            if skewAngle >= pi
                skewAngle = skewAngle - pi;
            end;
            b = p + [cos(skewAngle), sin(skewAngle)] * len;
            e = p - [cos(skewAngle), sin(skewAngle)] * len;

            line([b(1), e(1)], [b(2), e(2)], 'LineWidth', 3);
        end;
    end;
end;
hold off;