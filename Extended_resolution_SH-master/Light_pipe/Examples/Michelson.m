%LightPipes for Matlab
%Simulation of a Michelson interferometer
%One of the mirrors tilted
%F.A. van Goor, August 1998.

clear;

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;
rad=1;
mrad=1e-3*rad;

lambda=632.8*nm;
size=10*mm;
N=500;
R=3*mm;
z1=3*cm;
z4=5*cm;
RBS=0.5;
ty=0.0*mrad;
tx=5*mrad;
f=40*cm;
z3=7*cm+lambda/4;
z2=13*cm;

%A weak converging beam using a weak positive lens:
F=LPBegin(size,lambda,N);
F=LPGaussAperture(R,0,0,1,F);
F=LPLens(f,0,0,F);
%Propagation to the beamsplitter:
F=LPForvard(z1,F);
%Splitting the beam and propagation to mirror #2:
F2=LPIntAttenuator(1-RBS,F);
F2=LPForvard(z3,F2);
%Introducing tilt and propagating back to the beamsplitter:
F2=LPTilt(tx,ty,F2);
F2=LPForvard(z3,F2);
F2=LPIntAttenuator(RBS,F2);
%Splitting off the second beam:
F10=LPIntAttenuator(RBS,F);
figure(1);
F1=LPForvard(z2*2,F10);
F1=LPIntAttenuator(1-RBS,F1);
%Recombining the two beams and propagation to the screen:
F=LPBeamMix(F1,F2);
F=LPInterpol(size/3,N,0,0,0,1,F);
F=LPForvard(z4,F);
I=LPIntensity(1,F);
%plot the intensity on the screen (bitmap)
image(I*80);colormap(gray);axis off;axis square;
