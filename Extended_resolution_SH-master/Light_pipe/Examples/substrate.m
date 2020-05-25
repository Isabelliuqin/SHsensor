%LightPipes for Matlab
%Demonstrates the use of LPReflectMultilayer to simulate substrate reflection.
%F.A. van Goor

clear;

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;
rad=1;
%deg=3.1415927/180*rad;
deg=pi/180*rad;
lambda=500*nm;
size=30*mm;
N=8;
p=1; %p-Polarization
s=0; %s-Polarization
PolState=p;
N0=1.0;
Nsub=1.5;
Nlayer=1.5; %dummy layer with zero thickness
dlayer=0.0;

for i=1:90
	F=LPBegin(size,lambda,N);
   theta(i)=(i-1)*deg;
   F=LPReflectMultilayer(PolState,N0,Nsub,Nlayer,dlayer,theta(i),F);
   Int=LPIntensity(0,F);
   Ph=LPPhase(F);
   I(i)=Int(N/2,N/2);
   Phase(i)=Ph(N/2,N/2);
end

figure(1);
plot(I);
figure(2);
plot(Phase);