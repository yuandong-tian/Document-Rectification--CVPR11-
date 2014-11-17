function vis_3d_rects_mesh(pts3, rects)
% draw the mesh..
nRect = size(rects, 1);
tri = zeros(2*nRect, 3);

for i = 1:nRect
    tri(2*i-1, :) = rects(i, [1 2 3]);
    tri(2*i, :) = rects(i, [3 4 1]);
end;

%trimesh(tri, pts3(:, 1), pts3(:, 2), pts3(:, 3), 'EdgeColor', 'none',
%'FaceColor', 'interp');
%trimesh(tri, pts3(:, 1), pts3(:, 2), pts3(:, 3), 'EdgeColor', 'none', 'FaceLighting', 'gouraud', 'FaceColor', 'white');
trimesh(tri, pts3(:, 1), pts3(:, 2), pts3(:, 3), 'EdgeColor', 'black');
%light('Position', [0, 0, 1], 'Style', 'infinite');

grid on;
axis on;
xlabel('x');
ylabel('y');
zlabel('z');