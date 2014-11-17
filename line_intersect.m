function [intersect, c1, c2] = line_intersect(line1b, line1e, line2b, line2e)
% find the intersection of the two lines..
diff1 = line1e - line1b;
diff2 = line2b - line2e;
diff = line2b - line1b;

A = [diff1', diff2'];

if rank(A) < 2
    % two line is parallel..
    c1 = Inf;
    c2 = Inf;
    intersect = [NaN, NaN];
    return;
end;

M = (A'*A) \ A';

cs = M * diff';

intersect = line1b + diff1 * cs(1);

c1 = cs(1);
c2 = cs(2);