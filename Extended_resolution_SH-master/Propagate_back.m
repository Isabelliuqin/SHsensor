% Propagate back
function Uz0=Propagate_back(Uz,z,lambda,Fx,Fy,deltax)
FUz = deltax^2.*fftshift(fft2(fftshift(Uz)));
FUz0 = exp(1i*2*pi*(-z)/lambda).*exp(-1i*pi*lambda*(-z)*(Fx.^2+Fy.^2)).*FUz;
Uz0 = ifftshift(ifft2(fftshift(FUz0)))/deltax^2;

