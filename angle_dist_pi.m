function dist = angle_dist_pi(angle1, angle2)
% range = [-pi/2, pi/2), -pi/2 is the same as pi/2. 
d = angle1 - angle2;
dist = min(min(abs(d), abs(d + pi)), abs(d - pi));