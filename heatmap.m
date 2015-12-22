function [Z,zUnits] = heatmap(x,y,varargin)
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

% default parameters
histaxis = 'log';
histmode = 1;
histcolor = 'hot';

% set default bin edges to min/max values
% x0 = min(x);
% x1 = max(x);
% y0 = min(y);
% y1 = max(y);

%%%%%%%%%%%%%%%%
x0 = 10;
x1 = 101;
y0 = 10;
y1 = 101;
%%%%%%%%%%%%%%%%%

% set default number of bins to sqrt(nPts)
N = round(sqrt(numel(x)));
M = N;

% parse input options
switch nargin
    case 2
    case 3
        N = varargin{1};
        M = N;
    case 4
        N = varargin{1};
        M = varargin{2};
end


% set histogram bin positions
switch histaxis
    case 'lin'
        xBins = linspace(x0,x1,N+1);
        yBins = linspace(y0,y1,M+1);
        
    case 'log'
        % space bins logarithmically between 10 and 100
        xBins = logspace(log10(x0),log10(x1),N+1);
        yBins = logspace(log10(y0),log10(y1),M+1);
        
    case 'custom'
        % user provided custom bin edges - do nothing

    otherwise
        error('Invalid histogram axis mode')
end

% force bins into column vector
xBins = xBins(:);
yBins = yBins(:);

%% calculate normalization parameters

% bin data points into 2D histogram
Z = hist3([x(:) y(:)], 'Edges', {xBins,yBins});
Z = Z(1:end-1, 1:end-1);        % remove outliers

% calculate bin centers (for plotting axes)
xPos = xBins(1:end-1) + diff(xBins)/2;
yPos = yBins(1:end-1) + diff(yBins)/2;

% calculate bin width
dx = diff(xBins);
dy = diff(yBins);
DXDY = dy*dx';

nPts = sum(sum(Z));        % total number of data points


% histogram type
switch histmode
    % frequency distribution
    case 0
        zUnits = 'Frequency';

    % discrete probability distribution
    case 1
        Z = Z./nPts;
        zUnits = 'Discrete Probability';

    % discrete percentage probability distribution
    case 2
        Z = Z.*(100/nPts);
        zUnits = 'Discrete % Probability';
        
    % Frequency Density Distribution
    case 3
        Z = Z./DXDY;
        zUnits = 'Frequency Density';
        
    % Probability Density Distribution
    case 4
        Z = Z./(DXDY*nPts);
        zUnits = 'Probability Density';
    
    otherwise
        error('Invalid histogram mode')
end

% plot heatmap and correct axis labels
imagesc(Z)
axis xy


%% set x/y tick marks

% get current x/y tick positions
%     xLabel = xPos(get(gca,'XTick'));
%     yLabel = yPos(get(gca,'YTick'));
%     set(gca,'XTickLabel',round(xLabel,3,'significant'))
%     set(gca,'YTickLabel',round(yLabel,3,'significant'))

% desired label values
%%%%%%%%
xMarks = 10:20:100; %logspace(1,2,3);
yMarks = 10:20:100; %logspace(1,2,3);
%%%%%%%%

% align desired tick values with correct image pixel coordinates
xTick = zeros(size(xMarks));
for i=1:numel(xMarks)
    [~,idx] = min(abs(xPos-xMarks(i)));
    xTick(i) = idx;
end

yTick = zeros(size(yMarks));
for i=1:numel(yMarks)
    [~,idx] = min(abs(yPos-yMarks(i)));
    yTick(i) = idx;
end

% remove duplicates and assign actual tick values
xTick = unique(xTick);
xLabel = round(xPos(xTick),2,'significant');

yTick = unique(yTick);
yLabel = round(yPos(yTick),2,'significant');

% set axis labels
set(gca,'TickDir','out')

set(gca,'XTick',xTick)
set(gca,'XTickLabel',xLabel)

set(gca,'YTick',yTick)
set(gca,'YTickLabel',yLabel)


%% set colormap
switch histcolor
    case 'hot'
        cMap = flipud(hot(100));
        cMap = cMap(25:100,:);
        cMap(1,:) = [1 1 1];
    case 'jet'
        cMap = jet(100);
        %cMap(1,:) = [1 1 1];
    case 'gray'
        cMap = flipud(gray);
    otherwise
        if exists
        else
            error('Invalid histogram color map selected')
        end
end

colormap(cMap)
colorbar

