function showfigs
% SHOWFIGS  brings all figure windows to front

FH = flipud(findobj('Type','figure')).';

for f=FH
    figure(f)
end
