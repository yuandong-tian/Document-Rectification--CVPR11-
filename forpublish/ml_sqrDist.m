function SqrDist = ml_sqrDist(Data1, Data2)
% Compute square Euclidean distances.
% Usages:
% Inputs:
%   Data1: a d*n matrix representing a set of d-dim data points.
%   Data2: a d*m matrix representing a second set of d-dim data points.
% Outputs:
%   SqrDist: a n*m matrix, the entry in i_th row and j_th column represents
%       the square Euclidean distance between the i_th data point of Data1
%       and the j_th data point of Data2.
% See also: function pdist from Statistics ToolBox. 
% However, pdist is much slower than this function. 
% By Minh Hoai Nguyen (minhhoai@gmail.com)
% Date: 13 Feb 07

n = size(Data1,2);
m = size(Data2,2);
x2 = sum(Data1.^2, 1)';
y2 = sum(Data2.^2, 1);    
SqrDist = x2(:,ones(1, m)) + y2(ones(n,1),:) - 2*Data1'*Data2;
