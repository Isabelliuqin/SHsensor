% LightPipes for Matlab
% calculation of the intensity near the
% focus of a lens with LPSteps.
% F.A. van Goor

clear;

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;

lambda=632.8*nm;
size=4*mm;
N=100;
R=1.5*mm;
dz=10*mm;
f=50*cm;
n=(1+0.1*i)*ones(N,N);

F=LPBegin(size,lambda,N);
F=LPCircAperture(R,0,0,F);
F=LPLens(f,0,0,F);
for i=1:100
   F=LPSteps(dz,1,n,F);
   I=LPIntensity(0,F);
   for k=1:N
      Icross(i,k)=I(N/2,k);
   end
end
figure;
surfl(Icross);
shading interp;
colormap(copper);
axis off;
rotate3d on;