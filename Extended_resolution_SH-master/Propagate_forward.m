% Propagate forward
function Uz=Propagate_forward(Uz0,z,lambda,Fx,Fy,deltax)
% Take FT in the plane z=0
FUz0 = deltax^2.*fftshift(fft2(fftshift(Uz0)));
% Multiply with transfer function for propation over distance z
FUz = exp(1i*2*pi*z/lambda).*exp(-1i*pi*lambda*z*(Fx.^2+Fy.^2)).*FUz0;
% Take inverse FT
Uz = ifftshift(ifft2(fftshift(FUz)))/deltax^2;
