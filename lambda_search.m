function [ind_b, ind_e, lambda] = lambda_search(xs, x)
% xs is a sorted vector in the ascending order, x is one value
% find ind, and lambda so that xs(ind_b) <= x < xs(ind_e),  (ind_e = ind_b + 1)
%     and x = (1 - lambda) * xs(ind_b) + lambda * xs(ind_e);
% if x <= xs(1), then ind_b = ind_e = 1, lambda = 0;
% if x >= xs(end), then ind_b = ind_e = end, lambda = 0;
ind_b = find(x >= xs, 1, 'last');
% bilinear interpolation...
if ~isempty(ind_b)
    if ind_b >= length(xs)
        ind_e = ind_b;
        lambda = 0;
    else
        ind_e = ind_b + 1;
        lambda = (x - xs(ind_b)) / (xs(ind_e) - xs(ind_b));
    end;
else
    ind_b = 1;
    ind_e = 1;
    lambda = 0;
end;
