function lines = trace_line(img, pt, dir, optionsTracing)
t1 = self_similar_tracing(img, pt, dir, optionsTracing);
t2 = self_similar_tracing(img, pt, dir + pi, optionsTracing);

lines = cell(size(pt, 1), 1);
for i = 1:size(pt, 1)
    lines{i} = [t2{i}(end:-1:2, :); t1{i}];
end;
