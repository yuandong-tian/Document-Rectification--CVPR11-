addpath('./forpublish');

rs_new2 = {};
% Please run ./download.sh to obtain the two mat files.
load ./intemediate/result_camera_ready_Mar23.mat; 
load ./intemediate/camera_ready_smallimages.mat;

% tracing parameters...
% optionsTracing = struct('patchSize', 21, 'nAngle', 30, 'step', 3, 'nHistory', 15, 'lambda', 0.001, 'nPoint', 100, 'accessRegion', accessRegion);

%%
tic
for i = 51; % to check other images, change "51" with [5, 51, 52, 65, 77]
    fprintf(1, 'deal with image = %d\n', i);
    % rs_new2{i}.bbox and rs_new2{i}.pts are manually labeled.
    % (rs_new2{i}.seeds can be traced from rs_new2{i}.pts using the )
    
    rs_new2{i}.bResample = false;
    rs_new2{i}.smallImg = imgsBatch{i};
    rs_new2{i}.scale = scales(i);
    rs_new2{i}.bScale = true;
    % tracing parameters..
    rs_new2{i}.lambda = 0.001;
    rs_new2{i}.step = 3;
    rs_new2{i}.resampleRatio = 0.5;
    %rs{i}.bbox = bboxes(i, :);
%    rs{i}.p1 = p1(i, :);
%    rs{i}.p2 = p2(i, :);
%    rs{i}.bUseP = true;
    rs_new2{i}.bUseP = false; 
    
    % dataset...
    img = im2double(rgb2gray(imread(sprintf('./forpublish/%02d.jpg', i))));
    % img = dataset_document(i);
    
    rs_new2{i} = rectify_image_2_tracing(img, rs_new2{i});
    rs_new2{i} = rectify_image_2_vertical(img, rs_new2{i});
    rs_new2{i} = rectify_image_2_recon(img, rs_new2{i});    
    rs_new2{i} = rectify_image_2_rectify(img, rs_new2{i});        
    visualize_result(img, rs_new2{i});
end;    
t = toc;

%%
[imgBatch, scale, meanMag] = textreg_scale(img);

%%
rs.bResample = false;
rs.smallImg = imgBatch;
rs.scale = scale;
rs.bScale = true;
    % tracing parameters..
rs.lambda = 0.001;
rs.step = 3;
rs.resampleRatio = 0.5;
%rs.bbox = [426, 45, 1037, 708];
rs.bbox = [20, 15, 628, 480];
    %rs{i}.bbox = bboxes(i, :);
%    rs{i}.p1 = p1(i, :);
%    rs{i}.p2 = p2(i, :);
%    rs{i}.bUseP = true;
rs.bUseP = false; 

rs = rectify_image_2_tracing(img, rs);
rs = rectify_image_2_vertical(img, rs);
rs = rectify_image_2_recon(img, rs);
rs = rectify_image_2_rectify(img, rs);
