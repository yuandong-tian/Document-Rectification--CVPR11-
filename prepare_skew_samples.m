function [sampleSkewXs, sampleSkewYs, skewDirs] = prepare_skew_samples(patchXs, patchYs, dirs, nSide)
sampleSkewXs = zeros(1, length(patchXs));
sampleSkewYs = zeros(length(patchYs), 1);

for i = 1:length(patchXs)
    sampleSkewXs(i) = patchXs(i) + nSide / 2;
end;

for j = 1:length(patchYs)
    sampleSkewYs(j) = patchYs(j) + nSide / 2;
end;

skewDirs = (dirs - 1) / 64 * pi + pi / 2;
skewDirs(skewDirs >= pi) = skewDirs(skewDirs >= pi) - pi;