%LightPipes for Matlab
%Shearing interferometer with aberrated wavefront.

clear;

m=1;
cm=1e-2*m;
mm=1e-3*m;
nm=1e-9*m;

size=4*cm;
lambda=500*nm;
N=256;
R=1*cm;
f=-20*m;
z1=50*cm;
z2=50*cm;
D=3*mm;
D1=1*mm;
Rplate=0.5;

F=LPBegin(size,lambda,N);
F=LPCircAperture(R,0,0,F);
%F=LPLens(f,0,0,F);
F=LPZernike(2,2,7*mm,10,F);
F=LPForvard(z1,F);
F1=LPIntAttenuator(Rplate,F);
F2=LPIntAttenuator(1-Rplate,F);
F2=LPInterpol(size,N,D,D1,0,1,F2);
F=LPBeamMix(F1,F2);
I=LPIntensity(1,F);

str1=sprintf('Astigmatism with:\nLPZernike(2,2,7*mm,10,F)');
figure(1);
subplot(1,1,1),imshow(I),title(str1);
