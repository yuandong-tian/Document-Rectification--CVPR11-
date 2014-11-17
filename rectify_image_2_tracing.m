function r = rectify_image_2_tracing(img, r)
% default value...everything is false...
r = argutil_setdefaults(r, 'bScale', false, 'bResample', false, 'bRefine', false, 'bVertical', false, ...
                           'bCoord1', false, 'b3D', false, 'bLight', false, 'b3D_prop', false, 'bCoord2', false, ...
                           'bRect1', false, 'bRect2', false, 'bRect3', false, 'bUseP', false);
                       
% set the dependency, a DAG...
d.dependency = { {'bResample', 'bScale'}, ...
                 {'bRefine', 'bResample'}, ...
                 {'bVertical', 'bScale'}, ...
                 {'bCoord1', 'bVertical', 'bRefine'}, ...
                 {'b3D', 'bCoord1'}, ...
                 {'bLight', 'b3D'}, ...
                 {'b3D_prop', 'b3D'}, ...
                 {'bCoord2', 'b3D_prop'}, ...
                 {'bRect1', 'bCoord1'}, ...
                 {'bRect2', 'bCoord2'}, ...
                 {'bRect3', 'bCoord2', 'bLight'} };
    
d.allbFields = {};           
for i = 1:length(d.dependency)
    d.allbFields = [d.allbFields, d.dependency{i}];
end;
d.allbFields = unique(d.allbFields);           

d.dependency_indices = cell(length(d.dependency), 1);
for i = 1:length(d.dependency)
    d.dependency_indices{i} = cellfun(@(x)(strmatch(x, d.allbFields, 'exact')), d.dependency{i});
end;

% --------------------------------
% all the parameters...
% --------------------------------
r.dir = 0;
r.nSide = 100;
r.nCol = 10;
[m, n] = size(img);
camera_FOF = 60 / 180 * pi; % cvpr parameters...
%camera_FOF = 15 / 180 * pi;
r.focal_length = max(n, m) / tan(camera_FOF/2) / 2;

% -------------------
% dependency
% -------------------
r = set_dependency(r, d);

% ---------------------------
% image scaling...
% ---------------------------
if ~r.bScale
    [r.smallImg, r.scale] = textreg_scale(img);
    r.bScale = true;
end;

% ---------------------------
% Text line tracing .....
% ---------------------------
if ~r.bResample
    rand('twister',5489);
    if r.bUseP
        [r.trajsUpper, r.trajsLower, r.trajsAll, r.trajsSigma, ...
            r.trajsValid, r.upperbound, r.lowerbound, r.lowerfirst, r.lowerlast] = find_text_lines_seed_resample(r.smallImg, r.dir, [], r.p1, r.p2, r.step, r.lambda, r.resampleRatio);
    else
        if isfield(r, 'seeds')
            seeds = r.seeds;
        else
            seeds = [];
        end;
        [r.trajsUpper, r.trajsLower, r.trajsAll, r.trajsSigma, ...
            r.trajsValid, r.upperbound, r.lowerbound, r.lowerfirst, r.lowerlast] = find_text_lines_seed_resample(r.smallImg, r.dir, r.bbox, [], [], seeds, r.step, r.lambda, r.resampleRatio);
    end;
    
    r.bResample = true;    
    draw_traj2(r.smallImg, r.trajsUpper, r.trajsLower);
    drawnow;
end;

if ~r.bRefine
    r.refinedTrajs = local_refine_textline3(img, r.upperbound/r.scale, r.lowerbound/r.scale, trajs_scale(r.trajsAll, 1/r.scale), r.trajsValid, r.lowerfirst);
    r.refinedTrajs_s = cellfun(@(x)(kernel_smooth(x, 200, 2)), r.refinedTrajs, 'UniformOutput', false);
    
    r.bRefine = true;
end;



function r = set_dependency(r, d)
% check the dependency: an item is set to false if its dependency is not satisfied...
for i = 1:length(d.dependency)
    nDep = length(d.dependency{i});
    table = zeros(nDep-1, 1);
    
    for j = 2:nDep
        table(j-1) = r.(d.dependency{i}{j});
    end;
    if any(~table)
        r.(d.dependency{i}{1}) = false;
    end;
end;
