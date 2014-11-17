function [outTrajs, intersects] = reorder_trajs(trajs, p1, p2, needpruning)
% reorder the seeds and remove bad ones...

% ordering is easy, put a vertical line at the center of bbox and find
% the order by lambdas...
% p1 = [nLowRes*ratio, 1];
% p2 = [nLowRes*ratio, mLowRes];

[lambdas, intersects, bIntersect] = trajs_intersect(p1, p2, trajs);
lambdas = lambdas(bIntersect);
outTrajs = trajs(bIntersect);
intersects = intersects(bIntersect, :);

% sorting according to lambdas
[~, sortedIndices] = sort(lambdas);
outTrajs = outTrajs(sortedIndices);
intersects = intersects(sortedIndices, :);
%
%
if needpruning
    % %         % then remove the lines that are too short...
    lens = cellfun(@(x)(sum(sqrt(sum(diff(x).^2, 2)))), outTrajs);
    %     if the length of the seed is substantially shorter/longer than its
    %     neighbors, then remove it..
    % second-order derivative...cd
    secondorder = [0; abs(lens(2:end-1) - (lens(1:end-2) + lens(3:end)) / 2); 0];
    isvalid = (secondorder < 20);
    outTrajs = outTrajs(isvalid);
    intersects = intersects(isvalid, :);
end;
% median filter..

% medianLen = median(lens);
% valid = abs(lens - medianLen) < 50;
% trajs = trajs(valid);
% intersects = intersects(valid, :);
