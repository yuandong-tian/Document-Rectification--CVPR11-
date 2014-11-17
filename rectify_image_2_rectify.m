function r = rectify_image_2_rectify(img, r)
% --------------------------------------
% Image rectification......
% --------------------------------------
% 1. rectified image without 3D reconstruction...
if ~r.bRect1
    r.rectImg = lines_rectify5(img, r.refinedTrajs_s, r.coords);
    
    r.bRect1 = true;
end;

if false
% 2. rectified image removing the foreshortening effects...
if ~r.bRect2
%     optionsRect.aspectRatio = r.meanTrajLen / r.crossRange;
%     optionsRect.light = [];
%     r.rectImg_rect = lines_rectify5(img, r.refinedTrajs_s, r.coords_rect, optionsRect);

    r.rectImg_rect = rects_rectify(r.recons, r.rects, r.ptsIndices, r.pts, img, 20, []);

    r.bRect2 = true;
end;

end;

% 3. rectified image removing the foreshortening effects and illumination...
if ~r.bRect3
%     optionsRect.trajNormals = r.trajNormals;
%     optionsRect.light = r.lightdir;
%     optionsRect.ambient = r.ambient;
%     r.rectImg_rect_normal = lines_rectify5(img, r.refinedTrajs_s, r.coords_rect, optionsRect);

    optionsRect.light = true;
    optionsRect.light_model = r.light_model;
    optionsRect.normals = r.normals_vertex;
    [r.rectImg_rect, r.rectImg_rect_normal, r.shading, r.rect_centers, r.rect_bWhitespaces] = rects_rectify(r.recons, r.rects, r.ptsIndices, r.pts, img, 20, r.lowerfirst, optionsRect);
    
    r.bRect3 = true;
end;
