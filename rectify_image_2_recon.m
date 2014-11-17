function r = rectify_image_2_recon(img, r)
[sampleSkewXs, sampleSkewYs, skewDirs] = prepare_skew_samples(r.patchXs, r.patchYs, r.dirs, r.nSide);
% scale them up..
sampleSkewXs = sampleSkewXs / r.scale;
sampleSkewYs = sampleSkewYs / r.scale;

% ------------------------------------
% Build the coordinate grid...
% ------------------------------------
if ~r.bCoord1
    r.coords = assign_coordinates(r.refinedTrajs_s, [], sampleSkewXs, sampleSkewYs, skewDirs);
    [r.pts, r.rects, r.ptsIndices, r.trajStarts, r.trajLambdas] = build_rectangles2(r.refinedTrajs_s, r.coords, r.nCol);
    
    r.bCoord1 = true;
end;

% ------------------------------
% 3D reconstruction part...
% then draw the coordinates and build the rectangle...
% ------------------------------
if ~r.b3D
    pts = camera_normalize(r.pts, size(img), r.focal_length);
    r.recons = recon_rectangles_varobs(pts, r.rects);
    
    % compute normals...
    [r.normals_rect, r.pixels, r.bWhiteSpace, r.pixel_locations] = compute_shading(img, r.recons, r.rects, r.pts, r.ptsIndices, r.lowerfirst);
    r.normals_vertex = compute_vertex_normal(r.normals_rect, r.rects);
    
    r.b3D = true;
end;

% -----------------------------------
% compute the lighting....
% -----------------------------------
if ~r.bLight
    sel = r.bWhiteSpace;
    r.light_model = light_train(r.pixel_locations(sel, :), r.normals_rect(sel, :), r.pixels(sel));

    r.bLight = true;
end;

% ------------------------------------
% Propagate the 3D information back to 2D trajs...
% ------------------------------------
% put z values back on trajsAll_smoothed, using the trajIndices, trajStarts
% and trajLambdas for vertices
if ~r.b3D_prop
    r.trajs3D = put_z_to_trajs(r.refinedTrajs_s, r.recons, r.ptsIndices, r.trajStarts, r.trajLambdas);
    [r.meanTrajLen, r.crossRange] = compute_range_traj3(r.trajs3D);
    r.trajNormals = distribute_normals(r.normals_vertex, r.trajs3D, r.ptsIndices, r.trajStarts, r.trajLambdas);
    
    r.b3D_prop = true;
end;

% ------------------------------------
% Build the coordinate grid, the second time to get rid of the forshortening effects...
% ------------------------------------
if ~r.bCoord2
    r.coords_rect = assign_coordinates(r.refinedTrajs_s, r.trajs3D, sampleSkewXs, sampleSkewYs, skewDirs);
    [r.pts_rect, r.rects_rect] = build_rectangles2(r.refinedTrajs_s, r.coords_rect, r.nCol);
    
    r.bCoord2 = true;
end;
