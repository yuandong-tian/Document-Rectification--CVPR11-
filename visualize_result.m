function visualize_result(img, r, options)
if ~exist('options', 'var')
    options = [];
end;

options = argutil_setdefaults(options, 'rectVertical', true, 'width', 2000, 'phoMulti', 1, 'alpha', 1, 'beta', 1, 'filename', []);
% compute the bbox that covers the coordinate grid
if isfield(r, 'pts')
    mins = min(r.pts, [], 1);
    maxs = max(r.pts, [], 1);

    % leave the same margin for both sides..
    marginx = round( (options.width - (maxs(1) - mins(1) + 1)) / 2 );
    marginy = 100;
    options.bbox = [mins(1) - marginx, mins(2) - marginy, maxs(1) + marginx, maxs(2) + marginy];
    options.bbox = bb_rectify(options.bbox, size(img, 2), size(img, 1));
else
    options.bbox = [1, 1, size(img, 2), size(img, 1)];
end;

if isfield(r, 'bbox')
    figure; 
    imshow(r.smallImg);
    hold on; 
    bb_show(r.bbox, 'r', 2);
end;

bboxSmall = round(options.bbox * r.scale);

if r.bResample
    figure;
    options.valid = r.trajsValid;
    %draw_traj(r.smallImg, r.trajsAll, options);
    draw_traj2(r.smallImg, r.trajsUpper, r.trajsLower);
    bb_axis(bboxSmall);

    title('text tracing and resampling');
end;

if r.bRefine
    figure;    
    draw_traj(img, r.refinedTrajs_s);
    bb_axis(options.bbox);
    
    title('text refinement');
end;

if r.bVertical
    figure;
    vis_vertical(r.smallImg, r.dirs, r.patchXs, r.patchYs, r.nSide);
    bb_axis(bboxSmall);
    
    title('vertical estimation');
end;

if r.bCoord1
    figure;
    imshow(img); 
    hold on; 
    vis_2d_rects(r.pts, r.rects);
    title('coordinate grid');
    bb_axis(options.bbox);    
end;
% 
if r.bCoord2
    figure;
    imshow(img); 
    hold on; 
    vis_2d_rects(r.pts_rect, r.rects_rect);
    title('coordinate grid 2');
end;
if r.b3D
    figure;
    imshow(img);
    hold on;
    vis_2d_rects(back_project(r.recons, size(img), r.focal_length), r.rects, 'r');
    vis_2d_rects(r.pts, r.rects, 'b');
    title('back projection error');
end;

if r.b3D && r.bLight
    figure;
    %colors = r.normals_vertex * r.lightdir(:);
%     vis_3d_rects_shading(r.recons, r.rects, colors);
%     colormap(gray);
    vis_3d_rects_mesh(r.recons, r.rects);
    title('3D reconstruction.');
    axis off;
    axis equal;
end;

if r.bRect1 && ~r.bRect2 && ~r.bRect3
    figure;
    imshow(r.rectImg);
end;

if r.bRect1 && r.bRect2 && ~r.bRect3
    figure;
    subplot(1, 2, 1);
    imshow(r.rectImg);
    subplot(1, 2, 2);
    imshow(r.rectImg_rect);
end;

if false

if r.bRect1 && r.bRect2 && r.bRect3
    figure;
    
    if options.rectVertical
        subplot(3, 1, 1);
        imshow(r.rectImg * options.alpha);
        subplot(3, 1, 2);
        imshow(r.rectImg_rect * options.beta);
        subplot(3, 1, 3);
        imshow(r.rectImg_rect_normal * options.phoMulti);
    else
        subplot(1, 3, 1);
        imshow(r.rectImg * options.alpha);
        subplot(1, 3, 2);
        imshow(r.rectImg_rect * options.beta);
        subplot(1, 3, 3);
        imshow(r.rectImg_rect_normal * options.phoMulti);
    end;
    
%     start = min(r.rectImg_rect_normal(:));
%     span = max(r.rectImg_rect_normal(:)) - start;
%     
%     imshow( (r.rectImg_rect_normal - start) / span);
end;

end;
if r.bRect3
    figure;
    imshow(r.rectImg_rect);
    figure;
    
    valid = ~isnan(r.rectImg_rect);
    mean_rect = mean(r.rectImg_rect(valid));
    mean_rect_normal = mean(r.rectImg_rect_normal(valid));
    rectImg_rect_normal = r.rectImg_rect_normal / mean_rect_normal * mean_rect;
    
    imshow(rectImg_rect_normal);
    % draw the histogram before and after the normalization of the light...
    % gather the statistics...
    n = size(r.rect_centers, 1);
    % cvpr uses bbox = [-5, -5, 5, 5]; 
    bbox = [-1, -1, 1, 1]; 
    stat_rect = [];
    stat_rect_normal = [];
    
    for i = 1:n
        this_bbox = bbox + repmat(round(r.rect_centers(i, :)), [1, 2]);
        patch_rect = im_crop(r.rectImg_rect, this_bbox);
        patch_rect_normal = im_crop(rectImg_rect_normal, this_bbox);        
        
        stat_rect = [stat_rect; patch_rect(:)];
        stat_rect_normal = [stat_rect_normal; patch_rect_normal(:)];
    end;
    
    % plot the statistics...
    [n1, x1] = hist(stat_rect, 256);
    [n2, x2] = hist(stat_rect_normal, 256);
    
    figure;
    plot(x1, n1, 'r-.', 'LineWidth', 2);
    hold on;
    plot(x2, n2, 'b-', 'LineWidth', 2);
    
    % save ...
    valid = ~isnan(r.rectImg_rect_normal);
    minval = min(r.rectImg_rect_normal(:));
    maxval = max(r.rectImg_rect_normal(:));
    
    rectImg_rect_normal(valid) = (r.rectImg_rect_normal(valid) - minval) / (maxval - minval);
    rectImg_rect_normal(~valid) = 0;
    
%    imwrite(rectImg_rect_normal, options.filename);
end;