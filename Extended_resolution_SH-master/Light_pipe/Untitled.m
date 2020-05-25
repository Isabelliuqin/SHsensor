%Propagation of a plane wave in 2D
clear all;
% initial data, all sizes in meter
lambda=1.06e-6; % wavelength
wave_num=2.*pi/lambda;
num_points=1024;
size=1e-2; % size of the calculation area
apert=2.5e-3/1.; % aperture size
Z=.05; % distance to propagate
dx=size/(num_points-1.); % step size
nc=num_points/2+1; % center coordinate

% Forming the initial field array:
for i = 1: num_points
x=(i-nc)*dx; % coordinate in the aperture
xxx(i)=x;
U(i)=complex(0); % zero padding
if abs(x) < apert
U(i)=1.; % plane wave in the aperture
end
end

subplot(2,2,1)
plot(xxx,abs(U).*abs(U)); % plot of the initial fiels
grid on
xlim([-size/2 size/2]);
drawnow;
subplot(2,2,3)
plot(xxx,angle(U));
xlim([-size/2 size/2]);
grid on
drawnow;


Uf=fftshift(fft(fftshift(U))); % FFT transform of the initial field

for i = 1:num_points
ic=i-nc;
serv = Z*sqrt(wave_num^2-(wave_num*ic*lambda/size)^2);
ff(i)= exp(complex(0.,1)* serv);
% filt(i)= exp(-(ic^2/(num_points/40)^2));
% ff(i)= ff(i) * filt(i);
end
U=fftshift(ifft(fftshift(Uf .* ff))); % transform back
subplot(2,2,2)
plot(xxx,abs(U).*abs(U));
xlim([-size/2 size/2]);
grid on
drawnow;
subplot(2,2,4)
plot(xxx,angle(U));
xlim([-size/2 size/2]);
grid on
drawnow;