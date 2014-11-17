function [smoothed_signal, dominantSigmas] = adaptive_smooth(signal, windowSize)
% apply fourier analysis on each window size, estimate the dominant
% frequency, and remove high freqs...

% partition the signals and perform fourier analysis so that we get the
% dominant freq, then smooth the signal using sigma that changes with the dominant freq...

n = length(signal);
starts = 1:windowSize:n;
if starts(end) + windowSize > n
    starts(end) = n - windowSize + 1;
end;

dominantSigmas_sample = zeros(length(starts), 1);

% perform fourier analysis.
for i = 1:length(starts)
    sel = starts(i):starts(i)+windowSize-1;
    coeffs = fft(signal(sel) - mean(signal(sel)));
    % find the dominant one...
    [maxVal, maxIndex] = max(abs(coeffs(1:floor(windowSize/2))));
    dominantSigmas_sample(i) = windowSize / maxIndex / 5;
end;

% simple local linear interpolate...
dominantSigmas = linear_interp(dominantSigmas_sample, starts + windowSize/2, (1:n)');

smoothed_signal = zeros(n, 1);
% then smooth the signal 
for i = 1:n
    % blur the image locally...
    sigma = dominantSigmas(i);
    span = round(3*sigma);
    
    sel = (max(1, i - span):min(n, i + span))';
    filter = exp(- (sel - i).^2 / 2 / sigma^2);
    
    smoothed_signal(i) = sum(signal(sel) .* filter) / sum(filter);
end;

function xdense = linear_interp(x, t, tdense)
xdense = zeros(size(tdense));

for i = 1:length(tdense)
    ind_b = find(tdense(i) >= t, 1, 'last');
    if isempty(ind_b)
        ind_b = 1;
        ind_e = 1;
        lambda = 1;
    elseif ind_b == length(t)
        ind_e = ind_b;
        lambda = 0;
    else
        ind_e = ind_b + 1;
        lambda = (tdense(i) - t(ind_b)) / (t(ind_e) - t(ind_b));
    end;
    
    xdense(i) = (1 - lambda) * x(ind_b) + lambda * x(ind_e);
end;