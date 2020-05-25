%Simulation with LightPipes for Matlab.
%March 1998. F.A. van Goor.
%Two slits with direct integration

clear;

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;
rad=1;

lambda=550*nm;
size=2.6*mm;
SizeNew=5*mm;
N=64;
w=0.1*mm;
h=2.5*mm;
x=0.5*mm;
phi=15*rad;
z=75*cm;
figure(1);

   F=LPBegin(size,lambda,N);
	F1=LPRectAperture(w,h,-x,0,0,F);
	F2=LPRectAperture(w,h,x,0,phi,F);
	F=LPBeamMix(F1,F2);
	clear F1;
	clear F2;
   F=LPForward(z,SizeNew,N,F);
   I=LPIntensity(1,F);
   subimage(I);
   Str=sprintf('z=%4.1f cm',z/cm)
   title(Str);
   axis off;
clear F;