function heatmap(x,y,varargin)
% GEN_HEATMAP  creates a 2D histogram using optional parameters
%
% gen_heatmap(x,y) plots the heatmap with sqrt(N) x sqrt(N) bins, where N
%     is the number of data points in the vectors x and y.
% gen_heatmap(x,y,N) uses NxN bins
% gen_heatmap(x,y,N,M) uses NxM bins
% %%%%gen_heatmap(x,y,N,'log') plots the heatmap on a log-log axis
%
% Note: x and y must be equal sized vectors
%
% NEED TO FIX THE AXES TO MATCH ACTUAL VALUES, NOT PIXELS

% default parameters
%cMap = flipud(gray);

% hot
cMap = flipud(hot(100));
cMap = cMap(25:100,:);
cMap(1,:) = [1 1 1];

N = round(sqrt(numel(x)));
M = N;

switch nargin
    case 2
    case 3
        N = varargin{1};
        M = N;
    case 4
        N = varargin{1};
        M = varargin{2};
end

% space bins logarithmically between 10 and 100
xBins = logspace(1,2,N);
yBins = logspace(1,2,M);

%xBins = linspace(10,100,N);
%yBins = linspace(10,100,M);

% create interpolation grid points
%[XX,YY] = meshgrid(xBins,yBins);

% bin data points into 2D histogram
ZZ = hist3([x(:) y(:)], 'Edges', {xBins,yBins});

% determine maximum number per bin
%Zmax = max(max(ZZ));

imagesc(ZZ)
%axis image
axis xy
colormap(cMap)
colorbar
