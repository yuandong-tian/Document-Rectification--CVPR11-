function patch = im_crop(img, bbox, options)
if ~exist('options', 'var') || ~options.check
    patch = img(bbox(2):bbox(4), bbox(1):bbox(3), :);
else
    [m, n, nChannel] = size(img);
    [newbbox, changes] = bb_rectify(bbox, n, m);
    if sum(abs(changes(:))) ~= 0
        if options.tolerate
            patch = img(newbbox(2):newbbox(4), newbbox(1):newbbox(3), :);
        elseif options.expand
            [w, h] = bb_getsize(bbox);
            if options.withnan || isnan(options.expandvalue)
                patch = nan(h, w, nChannel);
            elseif isfield(options, 'expandvalue')
                patch = repmat(options.expandvalue, [h, w, nChannel]);
            else
                patch = zeros(h, w, nChannel);
            end;
            bi = changes(2)+1;
            ei = h+changes(4);
            bj = changes(1)+1;
            ej = w+changes(3);
            
            if bi >= 1 && ei <= h && bj >= 1 && ej <= w
                patch(bi:ei, bj:ej, :) = img(newbbox(2):newbbox(4), newbbox(1):newbbox(3), :);
            end;
        else
            patch = [];
        end;
    else
        patch = img(newbbox(2):newbbox(4), newbbox(1):newbbox(3), :);
    end;
end;