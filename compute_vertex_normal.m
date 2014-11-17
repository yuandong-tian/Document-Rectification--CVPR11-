function normals_vertex = compute_vertex_normal(normals_rect, rects)
nVertex = max(rects(:));
normals_vertex = zeros(nVertex, 3);
nRect = size(rects, 1);

for i = 1:nRect
    for j = 1:4
        normals_vertex(rects(i, j), :) = normals_vertex(rects(i, j), :) + normals_rect(i, :);
    end;
end;
normals_vertex = normalize_v(normals_vertex);