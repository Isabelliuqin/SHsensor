%LightPipes for Matlab
%Rotational Shear interferometer with aberrated wavefront.

clear;

m=1;
cm=1e-2*m;
mm=1e-3*m;
nm=1e-9*m;
rad=1;

size=4*cm;
lambda=500*nm;
N=256;
PhiRot=90;
Rp=1*cm;
Rplate=0.5;

nZer=7;
mZer=3;
RZer=10*mm;
AZer=10*rad;

F=LPBegin(size,lambda,N);
F=LPCircAperture(Rp,0,0,F);
F=LPZernike(nZer,mZer,RZer,AZer,F);
F1=LPIntAttenuator(Rplate,F);
F2=LPIntAttenuator(1-Rplate,F);
F2=LPInterpol(size,N,0,0,PhiRot,1,F2);
F=LPBeamMix(F1,F2);
I=LPIntensity(1,F);

str1=sprintf('High order aberration with:\nLPZernike(%d,%d,%d*mm,%d*rad,F)',nZer,mZer,RZer/mm,AZer);
figure(1);
subplot(1,1,1),imshow(I),title(str1);

