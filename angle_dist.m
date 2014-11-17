function dist = angle_dist(angle1, angle2)
% range = [-pi, pi), -pi is the same as pi. 
d = angle1 - angle2;
dist = min(min(abs(d), abs(d + 2*pi)), abs(d - 2*pi));