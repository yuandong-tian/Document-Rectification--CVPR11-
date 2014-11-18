function options = argutil_setdefaults(varargin)
options = varargin{1};
ndefault = length(varargin) - 1;
if mod(ndefault, 2) ~= 0
    error('Argument Format error, sould be argutil_setdefaults(options, arg1, val1, arg2, val2, ...');
end;
ndefault = ndefault / 2;
for i = 1:ndefault
    if ~isfield(options, varargin{2*i})
        options = setfield(options, varargin{2*i}, varargin{2*i+1});
    end;
end;
