function shadings = light_evaluate(light_model, xs, normals)
% local model...
% pixel(x) = pho * (n(x) .* (l + light(x)) + A)
% while light(x) is some function...

n = size(xs, 1);

% ---------------------------------------
% light model 0: constant..
% light(x) = l0
% ---------------------------------------
% shadings = normals * light_model.l0 + light_model.ambient;

% ---------------------------------------
% light model 1: linear...
% light(x) = l0 + lx * x(1) + ly * x(2)
% ---------------------------------------
% c0 = normals * light_model.l0;
% c1 = normals * light_model.lx;
% c2 = normals * light_model.ly;
% 
% shadings = c0 + c1 .* xs(:, 1) + c2 .* xs(:, 2) + light_model.ambient;

%     brightness = (log(r.pixels(r.bWhiteSpace)) - 5.6914) / 0.4644;
%     light_w = [r.normals_rect(r.bWhiteSpace, :), ones(sum(r.bWhiteSpace), 1)] \ brightness;


% ---------------------------------------
% light model 2: rbf.....
% light(x) = l0 + \sum_i l_i rbf(x_i, x)
% ---------------------------------------
shadings = zeros(n, 1);
step = 50;
xpartition = 1:step:n;
if xpartition(end) ~= n
    xpartition = [xpartition, n+1];
end;

for i = 1:length(xpartition) - 1
    sel = xpartition(i):xpartition(i + 1)-1;
    
    [dx, dy] = ms_dist2(xs(sel, :), light_model.xs);
    distsSqr = dx.^2 + dy.^2;
    rbf = exp(-distsSqr / 2 / light_model.sigma.^2);
    shadings(sel) = sum((normals(sel, :) * light_model.ls') .* rbf, 2);
end;

shadings = shadings + normals * light_model.l0 + light_model.ambient;

% ---------------------------------------
% light model 3: rbf on just pixel values.......
% light(x) = x0 + \sum_i a_i rbf(x_i, x)
% ---------------------------------------
% shadings = zeros(n, 1);
% step = 50;
% xpartition = 1:step:n;
% if xpartition(end) ~= n
%     xpartition = [xpartition, n+1];
% end;
% 
% for i = 1:length(xpartition)-1
%     sel = xpartition(i):xpartition(i + 1)-1;
%     
%     [dx, dy] = ms_dist2(xs(sel, :), light_model.xs);
%     distsSqr = dx.^2 + dy.^2;
%     rbf = exp(-distsSqr / 2 / light_model.sigma.^2);
%     shadings(sel) = rbf * light_model.as;
% end;
% 
% shadings = shadings + light_model.ambient;
