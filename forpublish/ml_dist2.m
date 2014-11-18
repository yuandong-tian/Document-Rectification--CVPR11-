function [dx, dy] = ml_dist2(pos1, pos2)
% given pos1 a n1*2 matrix, pos2 a n2*2 matrix
% output: pairwise difference stored in n1 * n2 matrix dx and dy
n1 = size(pos1, 1);
n2 = size(pos2, 1);

dx = repmat(pos1(:, 1), 1, n2) - repmat(pos2(:, 1)', n1, 1);
dy = repmat(pos1(:, 2), 1, n2) - repmat(pos2(:, 2)', n1, 1);
