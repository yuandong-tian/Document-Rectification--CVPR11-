function pts0 = camera_normalize(pts, imgsize, focal_length)
offsets = repmat([imgsize(2), imgsize(1)] / 2, [size(pts, 1), 1]);
pts0 = (pts - offsets) / focal_length;
pts0(:, 1) = -pts0(:, 1);
