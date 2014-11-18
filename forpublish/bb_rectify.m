function [bbox, changes] = bb_rectify(bbox, w, h)
if ~exist('w', 'var') 
    w = Inf;
end;
if ~exist('h', 'var') 
    h = Inf;
end;

newbbox(1) = min(max(bbox(1), 1), w);
newbbox(2) = min(max(bbox(2), 1), h);
newbbox(3) = min(max(bbox(3), 1), w);
newbbox(4) = min(max(bbox(4), 1), h);

changes = newbbox - bbox;
bbox = newbbox;

% ensure xmin > xmax, ymin > ymax
if (bbox(1) > bbox(3))
    [bbox(1), bbox(3)] = swap(bbox(1), bbox(3));
end;
if (bbox(2) > bbox(4))
    [bbox(2), bbox(4)] = swap(bbox(2), bbox(4));
end;  
    
function [y, x] = swap(x, y)