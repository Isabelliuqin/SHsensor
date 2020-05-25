% LightPipes for Matlab
% Simulates a unstable resonator
%

clear;

m=1; nm=1e-9*m; mm=1e-3*m; cm=1e-2*m;

lambda=308*nm; size=14*mm; N=100; w=5.48*mm;
f1=-10*m; f2=20*m; L=10*m; Isat=1.0; alpha=1e-4; Lgain=1e4;

F=LPBegin(size,lambda,N); F=LPRandomIntensity(2,F); F=LPRandomPhase(5,1,F);
for i=1:10
   F=LPRectAperture(w,w,0,0,0,F);   F=LPGain(Isat,alpha,Lgain,F);
   F=LPLensFresnel(f1,L,F);   F=LPGain(Isat,alpha,Lgain,F);
   F=LPLensFresnel(f2,L,F);
   SR(i)=LPStrehl(F);
   F=LPInterpol(size,N,0,0,0,1,F);
   fprintf('Round trip %d Strehl ratio= %f \n',i,SR(i));
   F2=LPRectScreen(w,w,0,0,0,F);
   I=LPIntensity(1,F2);
   figure(1);   subplot(2,5,i);   imshow(I);   
end
F2=LPConvert(F2);
I=LPIntensity(1,F2);

figure(2);
subplot(2,1,1); plot(SR); xlabel('Number of Roundtrips'); ylabel('Strehl ratio');

figure(3); surfl(I); shading interp; colormap(copper); axis off;
title('Intensity distribution just behind the outcoupler'); rotate3d on;

%Far-field calculation:
z=1*m; f=40*m;
ff=z*f/(f-z);
F2=LPLens(f,0,0,F2);
F2=LPLensFresnel(ff,z,F2);
F2=LPConvert(F2);
I2=LPIntensity(1,F2);

figure(4);
surfl(I2); shading interp; colormap(copper); axis off;
title('Intensity distribution in the far field'); rotate3d on;

