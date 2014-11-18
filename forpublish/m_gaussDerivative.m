function filter = m_gaussDerivative(sigma)
% filter = m_gaussDerivative(sigma)
% Create 1D filter for Gaussian derivatie 
% By Minh Hoai Nguyen (minhhoai@cmu.edu)
% Date: 30 Sep 08

hSz = ceil(3*sigma);
filter = zeros(2*hSz+1,1);
u = hSz+1;
for i=1:length(filter)
    filter(i) = (i - u)*exp(-(i-u)^2/2/sigma^2)/sigma^3/sqrt(2*pi);
end;
    