% Find all the max point
clear all;
close all;

image=double(imread('\images\lens_300mm.bmp'));
ref=double(imread('\images\lens_reference.bmp'));
% camera data
cam_size=2048;
% Shack Hartmann raster data
npoints=140;
spot_size=12;
mask1=zeros(cam_size);% creat a mask set the border to zero
mask2=zeros(spot_size);
% Low frequence filter bandwidth
q_cutoff=20;

b=10;
ROI_y_up_bound=148-b;
ROI_y_low_bound=1831+b;
ROI_x_up_bound=185-b;
ROI_x_low_bound=1868+b;

mask1(ROI_x_up_bound:ROI_x_low_bound,ROI_y_up_bound:ROI_y_low_bound)=1;
image=uint8(image.*mask1);
ref=uint8(ref.*mask1);

ftimage=fftshift(fft2(image));
Absftimage=abs(ftimage);

ftref = fftshift(fft2(ref));
Absftref=abs(ftref);

%% Image operation
%% Find the x sidelobe maximum
Center_x=Absftimage(cam_size/2+1,:);% Center_x is Vector
% figure,plot(Center_x)
cutlength=1000;

Cut_center_x=Center_x(cam_size/2:cam_size/2+cutlength); % Searching at the first quadrant
Cut_center_x(1:10)=0;% Block center DC value
[Max_x,Max_x_idx0]=max(Cut_center_x);
% sidelobe index in x axis
Max_x_idx=Max_x_idx0+cam_size/2;

%% apply the low pass band filter and move to the center
Filtered_x=zeros(cam_size);
%Square filter
Filtered_x(cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff,cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff)=ftimage(cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff,Max_x_idx-q_cutoff:Max_x_idx+q_cutoff);

Abs_Filtered_x=abs(Filtered_x);
% figure('name','Abs_Filtered_x'),imagesc(Abs_Filtered_x)
%% Look for x slope
Ift_Filtered_x=ifft2(fftshift(Filtered_x));
Slope_x=angle(Ift_Filtered_x);
% figure('name','x slope of wavefront'),
% imagesc(Slope_x)

%% Find the y sidelobe maximum
Center_y=Absftimage(:,cam_size/2+1);
% figure,plot(Center_y)
Cut_center_y=Center_y(1:cutlength);

[Max_y,Max_y_idx]=max(Cut_center_y);

%% apply the low pass band filter and move to the center
Filtered_y=zeros(cam_size);
Filtered_y(cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff,cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff)=ftimage(Max_y_idx-q_cutoff:Max_y_idx+q_cutoff,cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff);
Abs_Filtered_y=abs(Filtered_y);
% figure('name','Abs_Filtered_y'),imagesc(Abs_Filtered_y)
%% Look for y slope
Ift_Filtered_y=ifft2(fftshift(Filtered_y));
Slope_y=angle(Ift_Filtered_y);
% figure('name','y slope of wavefront'),imagesc(Slope_y)

USlope_x=LPPhaseUnwrap(1,Slope_x);
USlope_y=LPPhaseUnwrap(1,Slope_y);

%% Reference operation

%% Find the x sidelobe maximum
Center_x=Absftref(cam_size/2+1,:);
Cut_center_x=Center_x(cam_size/2:cam_size/2+cutlength);
Cut_center_x(1:10)=0;
[Max_x,Max_x_idx0]=max(Cut_center_x);
Max_x_idx=cam_size/2+Max_x_idx0-1;
%% apply the low pass band filter and move to the center
Filtered_x_ref=zeros(cam_size);
Filtered_x_ref(cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff,cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff)=ftref(cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff,Max_x_idx-q_cutoff:Max_x_idx+q_cutoff);
Abs_Filtered_x_ref=abs(Filtered_x_ref);

%% Look for x slope
Ift_Filtered_x_ref=ifft2(fftshift(Filtered_x_ref));
Slope_x_ref=angle(Ift_Filtered_x_ref);

%% Find the y sidelobe maximum
Center_y=Absftref(:,cam_size/2+1);
Cut_center_y=Center_y(1:cutlength);
[Max_y,Max_y_idx]=max(Cut_center_y);

%% apply the low pass band filter and move to the center
Filtered_y_ref=zeros(cam_size);
Filtered_y_ref(cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff,cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff)=ftref(Max_y_idx-q_cutoff:Max_y_idx+q_cutoff,cam_size/2+1-q_cutoff:cam_size/2+1+q_cutoff);
Abs_Filtered_y_ref=abs(Filtered_y_ref);

%% Look for y slope
Ift_Filtered_y_ref=ifft2(fftshift(Filtered_y_ref));
Slope_y_ref=angle(Ift_Filtered_y_ref);

USlope_x_ref=LPPhaseUnwrap(1,Slope_x_ref);
USlope_y_ref=LPPhaseUnwrap(1,Slope_y_ref);

delta_slope_x=USlope_x-USlope_x_ref;
delta_slope_y=USlope_y-USlope_y_ref;
%% cut the center matrix without no slope information
% Cut area size
Len=1024*0.5;
sy=delta_slope_x((cam_size-Len)/2+1:(cam_size+Len)/2,(cam_size-Len)/2+1:(cam_size+Len)/2);
sx=-delta_slope_y((cam_size-Len)/2+1:(cam_size+Len)/2,(cam_size-Len)/2+1:(cam_size+Len)/2);

sx=(sx-mean(mean(sx)));
sy=(sy-mean(mean(sy)));
figure('name','Original slopes')
subplot(121),imagesc(sx)
subplot(122),imagesc(sy)

% sx=rot90(sx-mean(mean(sx)));
% sy=rot90(rot90(rot90((sy-mean(mean(sy))))));
% figure('name','Cut slopes')
% subplot(121),imagesc(sx)
% subplot(122),imagesc(sy)



[nx,ny]=size(sx);
I1=complex(0,1);
dfsx=fftshift(fft2(sx,nx,ny)); %FFT x
dfsy=fftshift(fft2(sy,nx,ny)); %FFT y 
check_dfsx=abs(dfsx);
check_dfsy=abs(dfsy);

%% Use the equation a(f_{x},f_{y})=-j*()/(^2+^2)

for i=1:nx
    for j=1:ny
        x(i,j)=i-(nx/2+1);
        y(i,j)=j-(ny/2+1);
        fx(i,j)=(1/nx)*x(i,j);
        fy(i,j)=(1/ny)*y(i,j);
        if (fx(i,j)==0)&(fy(i,j)==0)
            wf_ft(i,j)=0;
        else
            wf_ft(i,j)=I1*(fx(i,j)*dfsx(i,j)+fy(i,j)*dfsy(i,j))/(2*pi*(fx(i,j)^2+fy(i,j)^2+0/100000));
        end        
   end
end

check_wf_ft=abs(wf_ft);
wf_c=ifft2(fftshift(wf_ft));
wf=real(wf_c);
figure(2),mesh(wf)
