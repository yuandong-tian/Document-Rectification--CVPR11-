function draw_traj2(img, trajectories1, trajectories2, options)
if ~exist('options', 'var')
    options = [];
end;
options = argutil_setdefaults(options, 'firstN', Inf, 'magn', 100, 'scale', [], 'color1', 'r', 'color2', 'b', 'bbox', [1, 1, size(img, 2), size(img, 1)]);

if ~isempty(options.scale)
    img = imresize(img, options.scale);
else
    options.scale = 1;
end;

if ~isempty(img)
    imshow(img, 'InitialMagnification', options.magn);
end;
hold on;
for i = 1:length(trajectories1)
    if ~isempty(trajectories1{i})
        range = 1:min(options.firstN, size(trajectories1{i}, 1));
        plot(trajectories1{i}(range, 1) * options.scale, trajectories1{i}(range, 2) * options.scale, [options.color1 '-'], 'LineWidth', 2);
    end;
end;
for i = 1:length(trajectories2)
    if ~isempty(trajectories2{i})
        range = 1:min(options.firstN, size(trajectories2{i}, 1));
        plot(trajectories2{i}(range, 1) * options.scale, trajectories2{i}(range, 2) * options.scale, [options.color2 '-'], 'LineWidth', 2);
    end;
end;
axis([options.bbox(1), options.bbox(3), options.bbox(2), options.bbox(4)]);
hold off;
