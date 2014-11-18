function bbox = bb_fromCenterSize(c, s)
c = c(:);
s = s(:);
l = round(s / 2);
r = s - l;

bbox = [c - l + 1; c + r]';