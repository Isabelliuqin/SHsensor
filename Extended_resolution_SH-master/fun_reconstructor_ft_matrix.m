% [wf]=fun_reconstructor_ft_matrix(sy,sx,rflag)(sy,sx,rflag)
% Fouier transfrom reconstructor
% Reconstruction the wavefront with slopes by using Fourier transform
% sx,sy: measured slopes
% rflag: reconstructor flag

function [wf,wf_ft]=fun_reconstructor_ft_matrix(sy,sx,rflag)

disp('Reconstructing the wavefront...');
[nx,ny]=size(sx);
[yy,xx] = meshgrid(-ny/2:1:ny/2-1,-nx/2:1:nx/2-1);    
fx = xx/nx;
fy = yy/ny;

dfsx=fftshift(fft2(sx,nx,ny)); %FFT sx
dfsy=fftshift(fft2(sy,nx,ny)); %FFT sy 

%% Use the equation a(fx,fy)=-j*(fx*dfsx+fy*dfsy)/(2*pi*(fx^2+fy^2)
if rflag ==1
	wf_ft = -i.*(fx.*dfsx+fy.*dfsy)./(2*pi*(fx.^2+fy.^2));
	wf_ft(nx/2+1,ny/2+1) = 0.0;
elseif rflag ==2
	wf_ft = -i.*(sin(fx).*dfsx+sin(fy).*dfsy)./(2*pi*(sin(fx).^2+sin(fy).^2));
	wf_ft(nx/2+1,ny/2+1) = 0.0;
end

wf_c=ifft2(fftshift(wf_ft));
wf=real(wf_c);

end
