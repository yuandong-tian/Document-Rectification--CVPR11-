function bb_show(bboxes, col, width)
Nboxes = size(bboxes, 1);

if nargin <= 1
    col = 'r';
end;
if nargin <= 2
    width = 1;
end;

for i = 1:Nboxes
    plot([bboxes(i,1) bboxes(i,3) bboxes(i,3) bboxes(i,1) bboxes(i,1)], ...
        [bboxes(i,2) bboxes(i,2) bboxes(i,4) bboxes(i,4) bboxes(i,2)], ...
        col, 'LineWidth', width);
end