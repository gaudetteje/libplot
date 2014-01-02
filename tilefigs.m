function tilefigs(varargin)
% TILEFIGS  retiles all open figures to use the entire workspace
%
% TILEFIGS(FH) takes an array of figure handles, FH, and sequentially
% tiles the workspace in the order specified.
%
% TILEFIGS(COLS,ROWS) = retiles all open figures with user defined geometry
%
% TILEFIGS(FH,COLS,ROWS) places the figures with handles FH into a grid of
% COLS columns by ROWS rows.
%
% Extra options:
%   'dual'  Uses all space available on multiple monitors
% 	'keep'  Retains current figure width and height
% Usage:  TILEFIGS(FH,COLS,ROWS,OPT1,OPT2,...)
%
% Note:  MATLAB is inconsistent in how it handles multiple monitors.  Be
% aware that screen position (a la ScreenSize and MonitorPositions) may not
% be compatible with this script!
%
% By default, tiles are left-to-right, then top-to-bottom.

% To Do:
% - 'exclude',F - removes figures F from FH
% - 'dual' - forces use of dual monitors
% - 'create' - creates new figure if FH doesn't exist
% - 'disp',N - use specified display number N
% - 'nomenu' - turn off figure menubar
% - 'notool' - turn off figure toolbar
% - 'span',N,M - have figure span N rows / M columns
% - Fix multiple monitors (test with newer MATLAB versions)
% - Fix bug for multiple monitors of different sizes





% 


DUALDISPLAY = false;    % default to single monitor
KEEPRATIO = false;      % default to resize figure windows

% separate optional arguments
flags = cellfun(@ischar,varargin);
opts = varargin(flags);
args = varargin(~flags);

switch numel(args)
    case 0
        FH = flipud(findobj('Type','figure')).';
    case 1
        FH = varargin{1};
    case 2
        FH = flipud(findobj('Type','figure')).';
        nCol = varargin{1};
        nRow = varargin{2};
    case 3
        FH = varargin{1};
        nCol = varargin{2};
        nRow = varargin{3};
    otherwise
        error('Incorrect number of non-char arguments entered')
end

% handle extra parameters
for k = 1:numel(opts)
    switch(opts{k})
        case 'keep'
            KEEPRATIO = true;
        case 'dual'
            DUALDISPLAY = true;
        otherwise
            error('Unknown flag "%s"',f)
    end
end

% set total number of figures to iterate over
nFigs = length(FH);

% auto calculate row/column geometry
if ~exist('nCol','var')
    nCol = ceil(sqrt(nFigs));
    nRow = ceil(sqrt(nFigs));
    
%     %if N odd, tile into odd x odd
%     %if N even, tile into odd x even, or even x odd or, even x even
%     A = A(3)*A(4);     % total available area (pixels^2)
%     a = A/N;           % available area/window (pixels^2)
%     z = floor(sqrt(a));       % width/height of square unit (pixels)
%     nRow = ?;
%     nCol = ?;
end
N = nRow*nCol;          % total number of tiles


% define window margins 
if ispc             % (Tested on R2007b on WinXP and R2011b on Win7)
    xMar = 4;           % nRow border margin [pixels]
    yMar = 4;           % nCol border margin [pixels]
    xOffset = 0;        % push figures right [pixels]
    yOffset = 0;        % push figures up [pixels]
    titleMar = 26;      % title bar margin [pixels]
    menuMar = 21;       % menu margin [pixels]
    toolMar = 27;       % figure toolbar margin [pixels]
elseif ismac        % (Tested with R2008B on x86-based Mac OSX 10.5.8)
    xMar = 0;           % nRow border margin [pixels]
    yMar = 0;           % nCol border margin [pixels]
    xOffset = 1;        % push figures right [pixels]
    yOffset = -17;      % push figures up [pixels]
    titleMar = 24;
    menuMar = 23;
    toolMar = 28;
elseif isunix       % (Tested with R2011b on 32-bit openSuSE 11.3, KDE 4.4.4, kernel 2.6.34.10-0.2-desktop)
    xMar = 4;           % nRow border margin [pixels]
    yMar = 4;           % nCol border margin [pixels]
    xOffset = 0;        % push figures right [pixels]
    yOffset = 0;        % push figures up [pixels]
    titleMar = 51;
    menuMar = 28;
    toolMar = 27;
else
    xMar = 0;
    yMar = 0;
    xOffset = 0;
    yOffset = 0;
    titleMar = 0;
    menuMar = 0;
    toolMar = 0;
end

% get display size of screen (or use user defined area)
if DUALDISPLAY
    A = get(0,'MonitorPositions');
    nDisplays = size(A,1);
else
    nDisplays = 1;
end
A = get(0,'ScreenSize');

assert((nRow && nCol),'Number of rows or columns is set to zero.')

% define the figure width & height [pixels]
xDim = A(1,3)*nDisplays/nRow;
yDim = A(1,4)*1/nCol;

% position for each index [pixels]
xPos = A(1,3) .* (0:nRow-1)./(nRow/nDisplays);
yPos = A(1,4) .* (nCol-1:-1:0)./nCol;

% index positions (integers)
xIdx = mod(0:N-1,nRow)+1;
yIdx = ceil((1:N)./nRow);

% generate (nRow,nCol) positions for each figure window [pixels]
x0 = xPos(xIdx);
y0 = yPos(yIdx);

% if more figures than tiles, repeat pattern
x0 = repmat(x0,1,ceil(nFigs/N));
y0 = repmat(y0,1,ceil(nFigs/N));

%% set position of each figure sequentially
for f = FH
    
    % skip over figure if not present
    if ~ishandle(f)
        % update index position vector
        x0(1)=[];
        y0(1)=[];
        continue
    end
    
    % adjust top margin of figure depending on menubar & toolbar
    if strcmp(get(f,'MenuBar'),'figure') && ~strcmp(get(f,'ToolBar'),'none')
        tMar = titleMar + menuMar + toolMar;
    elseif strcmp(get(f,'MenuBar'),'figure') && strcmp(get(f,'ToolBar'),'none')
        tMar = titleMar + menuMar;
    elseif strcmp(get(f,'MenuBar'),'none') && ~strcmp(get(f,'ToolBar'),'figure')
        tMar = titleMar;
    elseif strcmp(get(f,'MenuBar'),'none') && strcmp(get(f,'ToolBar'),'figure')
        tMar = titleMar + toolMar;
    else
        tMar = titleMar + menuMar + toolMar;
        warning('tilefigs:propVals','Unknown figure property values')
    end
    
    % override figure width/length with current setting
    if KEEPRATIO
        pos = get(gcf,'Position');
        xDim = pos(3);
        yDim = pos(4);
        xMar = 0;
        yMar = 0;
        tMar = 0;
    end
    
    % set approximate figure positions and dimensions
    units = get(f,'Units');             % save original units
    set(f,'Units','pixels');            % switch to pixels
    set(f,'Position', ...
        [x0(1) + xMar + xOffset ...
         y0(1) + yMar + yOffset ...
         xDim - 2*xMar ...
         yDim - 2*yMar - tMar]);        % set position with margins
    set(f,'Units',units);               % reset original units
    figure(f);                          % bring figure to front
    % update index position vector
    x0(1)=[];
    y0(1)=[];
end
