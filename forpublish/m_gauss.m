function filter = m_gauss(sigma)
% filter = m_gauss(sigma)
% Create 1D filter for Gaussian derivatie 
% By Yuandong Tian (tydsh@cmu.edu) in reference of m_gaussDerivative

hSz = ceil(3*sigma);
filter = zeros(2*hSz+1,1);
u = hSz+1;
for i=1:length(filter)
    filter(i) = exp(-(i-u)^2/2/sigma^2)/sigma/sqrt(2*pi);
end;
    