function [trajsUpper, trajsLower, trajsAll, trajsSigma, trajsValid, upperbound, lowerbound, lowerfirst, lowerlast] = find_text_lines_seed_resample(img, dir, bbox, p1, p2, seeds, step, lambda, ratio)
% algorithm:
%    sample nSeed points
%    reorder the seeds and remove bad ones..
%    resampling...

% get rid of the boundary...
scale = 0.5; %for cvpr...

nSeed = 100;
imgLowRes = imresize(img, scale);
[mLowRes, nLowRes] = size(imgLowRes);

accessRegion = textregion_classifier(imgLowRes, struct('filterSize', 15, 'sigma', 5));
%accessRegion = textregion_classifier(imgLowRes, struct('filterSize', 25, 'sigma', 10));
%accessRegion = repmat(true, size(imgLowRes));
%accessRegion = textregion_classifier(imgLowRes);

bboxRegion = repmat(false, size(accessRegion));

if ~isempty(bbox)
    bboxSmall = round(bbox * scale);
    bboxRegion(bboxSmall(2):bboxSmall(4), bboxSmall(1):bboxSmall(3)) = true;
    accessRegion = accessRegion & bboxRegion;
end;

% parameters for cvpr
% patchSize = 21, nAngle = 30, step = 5, nHistory = 15, lambda = 0.01, nPoint = 100
% which is incorrect. step = 5 gives bad result for image #52..

optionsTracing = struct('patchSize', 21, 'nAngle', 30, 'step', step, 'nHistory', 15, 'lambda', lambda, 'nPoint', 100, 'accessRegion', accessRegion);
%optionsTracing = struct('patchSize', 21, 'nAngle', 30, 'step', 3, 'nHistory', 15, 'lambda', 0.001, 'nPoint', 100, 'accessRegion', accessRegion);

if ~isempty(bbox) 
    if ~exist('seeds', 'var') || isempty(seeds)
        % random sample some points and get the seeds of text lines..
        [y, x] = find(accessRegion);

        nPoint = length(x);
        p = randperm(nPoint);

        x = x(p(1:nSeed));
        y = y(p(1:nSeed));

        % generate many lines...
        seeds = cell(nSeed, 1);
    
        for i = 1:nSeed
            if mod(i, 10) == 0
                fprintf(1, 'linetracing %d...\n', i);
            end;
            pt = [x(i), y(i)];
            seed = trace_line(imgLowRes, pt, dir, optionsTracing);
            seeds{i} = seed{1};
        end;
        needpruning = true;
    else
        needpruning = false;
    end;
    linex = bboxSmall(1) + (bboxSmall(3) - bboxSmall(1)) * ratio;
    [seeds, poses] = reorder_trajs(seeds, [linex, bboxSmall(2)], [linex, bboxSmall(4)], needpruning);
else
    % just trace the two lines...
    % make sure p1 is on top of p2...
    if p1(2) > p2(2)
        temp = p1;
        p1 = p2;
        p2 = temp;
    end;
    seeds = trace_line(imgLowRes, [round(p1 * scale); round(p2 * scale)] , dir, optionsTracing);
    poses = round([p1; p2] * scale);
end;


% then do the resampling...
[trajsUpper, trajsLower, trajsAll, trajsSigma, upperbound, lowerbound, lowerfirst, lowerlast] = trajs_resampling(imgLowRes, seeds, poses);

% cut the parts that is in the no access region...
nTraj = length(trajsAll);
trajsValid = cell(nTraj, 1);
for i = 1:nTraj
    thisTraj = round(trajsAll{i});
    indices = sub2ind([mLowRes, nLowRes], thisTraj(:, 2), thisTraj(:, 1));
    trajsValid{i} = accessRegion(indices);
end;
% group the lower and upper...
start = lowerfirst + 1;

for i = start:2:nTraj-1
    inter = trajsValid{i} & trajsValid{i+1};
    trajsValid{i} = inter;
    trajsValid{i+1} = inter;
end;

% scale everything up...
trajsAll = trajs_scale(trajsAll, 1 / scale);
trajsUpper = trajs_scale(trajsUpper, 1 / scale);
trajsLower = trajs_scale(trajsLower, 1 / scale);
trajsSigma = trajsSigma / scale;

upperbound = upperbound / scale;
lowerbound = lowerbound / scale;