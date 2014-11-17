function train_sel = pick_scatter(distsSqr, nTrain)
% pick points...
train_sel = zeros(nTrain, 1);
train_sel(1) = 1;
for i = 2:nTrain
    % max the min distance...
    minDists = min(distsSqr(train_sel(1:i-1), :), [], 1);
    [maxDist, train_sel(i)] = max(minDists);
end;
