function vis_2d_rects(pts, rects, col)
if ~exist('col', 'var')
    col = 'r';
end;

% convert rectangles into lines..
nRect = size(rects, 1);

if isempty(pts)
    return;
end;

edges = zeros(nRect, 4, 2);
nextj = [2, 3, 4, 1];
for i = 1:nRect
    for j = 1:4
        edges(i, j, :) = [rects(i, j), rects(i, nextj(j))];
    end;
end;

% eliminate repetitive patterns. 
edges = reshape(edges, [nRect*4, 2]);
reversed = edges(:, 1) > edges(:, 2);
edges(reversed, :) = [edges(reversed, 2), edges(reversed, 1)];

% unique
edges = unique(edges, 'rows');

hold on;
plot(pts(:, 1), pts(:, 2), 'b.', 'LineWidth', 2);
% draw the edges..
for i = 1:size(edges, 1)
    index1 = edges(i, 1);
    index2 = edges(i, 2);
    
    line([pts(index1, 1), pts(index2, 1)], [pts(index1, 2), pts(index2, 2)], 'Color', col, 'LineWidth', 2);
end;
hold off;