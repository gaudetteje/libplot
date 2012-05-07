function groupmesh
% GROUPMESH  plots a 3D mesh or waterfall plot showing distortion over
% various frequencies and amplitudes.

load DvsA.mat
frange = [20:10:50];
arange = a20';

[A,F]=meshgrid(arange,frange);
D = [d20 d30 d40 d50]';

%meshc(A,F,D);
waterfall(A,F,D);
xlabel('Amplitude (dBVrms)');
ylabel('Frequency (kHz)');
zlabel('THD+N (dB)');