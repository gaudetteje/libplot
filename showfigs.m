function varargout = showfigs(varargin)
% SHOWFIGS  brings all figure windows to front
%
% showfigs(FH) uses the handles listed in FH
% FH = showfigs brings all figure windows to front and returns the handles

switch (nargin)
    case 0
        FH = flipud(findobj('Type','figure')).';
    case 1
        FH = varargin{1};
    otherwise
        error('Incorrect number of input parameters')
end

for f=FH
    figure(f)
end

if nargout > 0
    varargout{1} = FH;
end