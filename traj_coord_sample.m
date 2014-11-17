function [lambdas, nodeIndices, inter_region] = traj_coord_sample(coord, xseq)
% given an increasing x sequence, find the points on the traj
nodeIndices = repmat(nan, length(xseq), 1);
lambdas = repmat(nan, length(xseq), 1);
inter_region = repmat(true, length(xseq), 1);

ind_before = find(xseq < coord(1));
if isempty(ind_before)
    ind_before = 0;
else
    % extrapolate..
    inter_region(ind_before) = false;
    nodeIndices(ind_before) = 1;
    lambdas(ind_before) = (xseq(ind_before) - coord(1)) / (coord(2) - coord(1));
end;

nodeIndex = 1;
i = ind_before(end)+1;

while i <= length(xseq)
    %fprintf('i = %d\n', i);
    nextNodeIndex = find(xseq(i) >= coord(nodeIndex:end), 1, 'last');
    nodeIndex = nextNodeIndex + nodeIndex - 1;
    
    if nodeIndex == length(coord)
        break;
    end;

    %fprintf(1, 'nodeIndex = %d\n', nodeIndex);
    % interpolate...
    nodeIndices(i) = nodeIndex;
    lambdas(i) = (xseq(i) - coord(nodeIndex)) / (coord(nodeIndex + 1) - coord(nodeIndex));
    i = i + 1;
end;

% 
if i <= length(xseq)
    % extrapolate..
    ind_after = i:length(xseq);
    inter_region(ind_after) = false;
    nodeIndices(ind_after) = length(coord) - 1;
    lambdas(ind_after) = (xseq(ind_after) - coord(end - 1)) / (coord(end) - coord(end - 1));
end