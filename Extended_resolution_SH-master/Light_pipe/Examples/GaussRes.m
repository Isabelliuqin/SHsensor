%Simulation of a Gaussian Unstable Resonator.
%The radiation starts from noise.

clear;

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;
rad=1;
mrad=1e-3*rad;

lambda=308*nm;
size=80*mm;
N=100;
r=10*mm;
f1=-1500*mm;
f2=3000*mm;
L=1.5;
T=1;
n=10;
tx=0.00*mrad;
ty=0.00*mrad;

figure(1);
F=LPBegin(size,lambda,N);
F=LPRandomIntensity(10000*rand,F);
F=LPRandomPhase(3333*rand,1,F);
for i=1:n
  F=LPSuperGaussAperture(r,1,0,0,T,F);
   %F=LPCircAperture(r,0,0,F);
   F=LPLensForvard(f1,L,F);
   F=LPLensForvard(f2,L,F);
   F=LPTilt(tx,ty,F);
   [F,NC(i)]=LPNormal(F);
   SR(i)=LPStrehl(F);
   fprintf('Round trip %d 	normcoeff= %f	Strehl ratio= %f\n',i,NC(i),SR(i));
   F=LPInterpol(size,N,0,0,0,1,F);
   Fext=LPSuperGaussScreen(r,1,0,0,1-T,F);
   I=LPIntensity(1,F);
   %Fext=LPCircScreen(r,0,0,F);
   Iext=LPIntensity(1,Fext);
   subplot(2,5,i);
   %imshow(I);
    surfl(I);
    axis off;
    shading interp;
    colormap(copper);
end
Fext=LPConvert(Fext);

figure(2);
subplot(2,1,1);
plot(SR);
xlabel('Number of Roundtrips');
ylabel('Strehl ratio');
subplot(2,1,2);
plot(NC);
xlabel('Number of Roundtrips');
ylabel('Normalization coefficient');

figure(3);
surfl(I);
shading interp;
colormap(copper);
axis off;
title('Internal Intensity distribution just before the outcoupler');
rotate3d on;

z=1000*m;
f1=200*m;
f2=-200*m;

F=LPLens(f1,0,0,Fext);
F=LPLensForvard(f2,z,F);
I=LPIntensity(1,F);
figure(4);
surfl(I);
shading interp;
colormap(copper);
axis off;
title('Intensity distribution in the far field');
rotate3d on;
