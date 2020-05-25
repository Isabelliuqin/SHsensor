%Simulation with LightPipes for Matlab.
%March 1998. F.A. van Goor.
%ThreeHoles.m
clear;

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;

lambda=550*nm;
size=5*mm;
N=150;
R=0.12*mm;
x=0.5*mm;
y=0.25*mm;
z=5*cm;

F=LPBegin(size,lambda,N);
F1=LPCircAperture(R,-x,-y,F);
F2=LPCircAperture(R,x,-y,F);
F3=LPCircAperture(R,0,y,F);
F=LPBeamMix(LPBeamMix(F1,F2),F3);
clear F1;
clear F2;
clear F3;
figure(1);
for i=1:10
   F=LPForvard(z,F);
   I=LPIntensity(1,F);
   subplot(2,5,i);
   subimage(I);
   Str=sprintf('z=%4.1f cm',i*z/cm)
   title(Str);
   axis off;
end
clear F;