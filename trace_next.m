function [nextp, nextpatch, bInf, minDist, dists] = trace_next(img, p, moveVecs, histPatches, regularizer, options)
optionsCrop.check = true;
optionsCrop.tolerate = false;
optionsCrop.expand = false;

nMove = size(moveVecs, 1);
nHistory = size(histPatches, 3);

bInf = false;
dists = Inf(nMove, 1);
for i = 1:nMove
    nextp = p + moveVecs(i, :);
    next_bbox = bb_fromCenterSize(nextp, options.patchSize);
    next_patch = im_crop(img, next_bbox, optionsCrop);
    if ~isempty(next_patch)
        % normalize the lighting..
        next_patch = process_patch(next_patch);
        % compute the distance between the two
        dist = 0;
        for j = 1:nHistory
            dist = dist + feval(options.func, next_patch, histPatches(:, :, j));
        end;
        % mean difference...
        dists(i) = dist / nHistory;
    else
        bInf = true;
    end;
end;

[minDist, minAngleIndex] = min(dists + regularizer);

nextp = p + moveVecs(minAngleIndex, :);
bbox = bb_fromCenterSize(round(nextp), options.patchSize);
nextpatch = im_crop(img, bbox, optionsCrop);
nextpatch = process_patch(nextpatch);

function patch = process_patch(patch)
patch = (patch - mean(patch(:))) / std(patch(:));
%patch = (patch - mean(patch(:)));