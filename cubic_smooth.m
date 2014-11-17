function ydense = cubic_smooth(x, y, xdense)
% fit a model y = ax^3 + bx^2 + cx + d
nPoint = length(x);

X = [x.^3, x.^2, x, ones(nPoint, 1)];
%X = [x.^4, x.^3, x.^2, x, ones(nPoint, 1)];

c = X \ y;

Xtest = [xdense.^3, xdense.^2, xdense, ones(size(xdense))];

ydense = Xtest * c;