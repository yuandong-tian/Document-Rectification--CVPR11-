function [trajsUpper, trajsLower, trajsAll, trajsSigma, upperbound, lowerbound, lowerfirst, lowerlast] = trajs_resampling(img, seeds, ps)
distThres = 20;
%distThres = 5;
smoothWindow = 41;
scaleFactor = 2;

nP = round(mean(cellfun(@(x)(size(x, 1)), seeds)));
seeds = cellfun(@(x)(traj_sample_len(x, nP)), seeds, 'UniformOutput', false);
% a little bit extrapolation...
% seeds = [2 * seeds{1} - seeds{2}; seeds; 2 * seeds{end} - seeds{end - 1}];
% ps = [2*ps(1, :) - ps(2, :); ps; 2*ps(end, :) - ps(end - 1, :)];

nTrace = length(seeds);
% assume seeds is from top to bottom..
trajs = {};
previ = 1;
for i = 2:nTrace
    % find the distance between two 
    s = ceil(sqrt(sum((ps(i, :) - ps(previ, :)).^2)));
    if s < distThres
        continue;
    end;
    thisTrajs = build_interp_scale(seeds{previ}, seeds{i}, s * scaleFactor);
    %thisTrajs = seeds{i};
    % trajs
    trajs = [trajs; thisTrajs];
    previ = i;
end;

% then do the expansion by searching over s..
% estimate s...
nTraj = length(trajs);
profile = zeros(nTraj, 1);

for i = 1:nTraj
    thisTraj = round(trajs{i});
    indices = sub2ind(size(img), thisTraj(:, 2), thisTraj(:, 1));
    profile(i) = mean(img(indices));
end;

% adaptive smoothness...
[profile, sigmas] = adaptive_smooth(profile, smoothWindow);
% find local minimal/maximal parts..
maxPoint = [false; profile(2:end-1) > profile(3:end) & profile(2:end-1) > profile(1:end-2); false];
minPoint = [false; profile(2:end-1) < profile(3:end) & profile(2:end-1) < profile(1:end-2); false];

% 
ss = [];
for i = 1:nTraj
    if minPoint(i)
        ss = [ss; -i];
    elseif maxPoint(i)
        ss = [ss; i];
    end;
end;
lowerfirst = ss(1) < 0;
lowerlast = ss(end) > 0;

upperbound = trajs{abs(ss(1))};
lowerbound = trajs{abs(ss(end))};

% use ss to compute trajLower/trajUpper
trajsUpper = {};
trajsLower = {};
trajsAll = {};
trajsSigma = [];
for i = 1:length(ss)-1
    ind1 = abs(ss(i));
    ind2 = abs(ss(i+1));
    
    thisTraj = (trajs{ind1} + trajs{ind2}) / 2;
    thisSigma = (sigmas(ind1) + sigmas(ind2)) / 2 / scaleFactor;
    
    if ss(i) > 0 && ss(i + 1) < 0
        trajsUpper = [trajsUpper; thisTraj];
    elseif ss(i) < 0 && ss(i + 1) > 0
        trajsLower = [trajsLower; thisTraj];
    end;
    
    trajsAll = [trajsAll; thisTraj];
    trajsSigma = [trajsSigma; thisSigma];
end;

function trajs = build_interp_scale(t1, t2, s)
trajs = cell(s + 1, 1);
trajs{1} = t1;
trajs{end} = t2;

for i = 1:s-1
    lambda = i / s;
    trajs{i + 1} = (1 - lambda) * t1 + lambda * t2;
end;
