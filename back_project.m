function pts = back_project(pts3, imgsize, focal_length)
offsets = repmat([imgsize(2), imgsize(1)] / 2, [size(pts3, 1), 1]);
proj = pts3(:, 1:2) ./ repmat(pts3(:, 3), [1, 2]);
proj(:, 1) = -proj(:, 1);
pts = proj * focal_length + offsets;
