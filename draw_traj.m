function draw_traj(img, trajectories, options)
if ~exist('options', 'var')
    options = [];
end;
options = argutil_setdefaults(options, 'firstN', Inf, 'magn', 100, 'scale', [], 'color', 'r', 'valid', [], 'bbox', [1, 1, size(img, 2), size(img, 1)]);

if ~isempty(options.scale)
    img = imresize(img, options.scale);
else
    options.scale = 1;
end;

if ~isempty(img)
    imshow(img, 'InitialMagnification', options.magn);
end;
hold on;
for i = 1:length(trajectories)
    if ~isempty(trajectories{i})
        nNode = size(trajectories{i}, 1);
        
        range = repmat(false, nNode, 1);
        range(1:min(options.firstN, nNode)) = true;
        
        % check valid cell
        if ~isempty(options.valid)
            range = range & options.valid{i};
        end;
        plot(trajectories{i}(range, 1) * options.scale, trajectories{i}(range, 2) * options.scale, [options.color '-'], 'LineWidth', 2);
    end;
end;
if ~isempty(img)
    axis([options.bbox(1), options.bbox(3), options.bbox(2), options.bbox(4)]);
end;
hold off;
