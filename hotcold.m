function h = hotcold(m)
%HOTCOLD    Red and Blue color map fading from light to dark around middle
%   HOTCOLD(M) returns an M-by-3 matrix containing a "hotcold" colormap.
%   HOTCOLD, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(hotcold)
%
%   See also HSV, HOT, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

if nargin < 1, m = size(get(gcf,'colormap'),1); end
n = fix(1/2*m);

r = [linspace(0,120,n)'; linspace(245,80,m-n)'];
g = [linspace(0,175,n)'; linspace(100,0,m-n)'];
b = [linspace(100,245,n)'; linspace(100,0,m-n)'];

h = [r g b]./255;
