function r = rectify_image_2_vertical(img, r)
% ------------------------------
% Vertical direction
% ------------------------------
if ~r.bVertical
    [r.funcVal, r.dirs, r.mask0, r.mask, r.patchXs, r.patchYs] = compute_second_direction(r.smallImg, r.nSide);
    
    r.bVertical = true;
end;

