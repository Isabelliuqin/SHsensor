%LightPipes for Matlab
%Shows a movie of a scanning Michelson interferometer
%F.A. van Goor, August 1998.

load MichelsonMovie.mat
figure(1);
image(I*80);colormap(gray);axis off;axis square;
movie(M,50,8);
