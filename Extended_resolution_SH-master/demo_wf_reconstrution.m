% Simulate the wavefront recontruction of a resolution target
clc;clear all;close all; % problem data, all sizes in meters 

lambda=633e-9; % wavelength
k=2*pi/lambda;

%% camera
cam_grid = 2048/1;  % grid sampling
pixel_size=5.5e-6;
cam_size=pixel_size*cam_grid;  % initial field size


%% SH 
pitch=1*63e-6; % SH sensor pitch
pitch_px = pitch/pixel_size;

lens_grid = 170;
lensarray_size = lens_grid*pitch;
sh_apert=lensarray_size/2;   % pupil half diameter
foc_sh=2.0e-3;    % SH sensor 
% npoints=cam_grid; % SH sensor grid sampling

%%%%%%%%%%%%%%%%%%%%%%%%%%%
apert=2e-2;     % pupil half diameter
FT1=0.05;       % First distance to object

FT2=0.5;        % distance of object to camera sensor

F = LPBegin(cam_size,lambda,cam_grid);                      % initial plane wave
F = LPRectAperture(apert,apert,0,0,0,F);                    % Pupil plane

F = LPForvard(FT1*1,F);                                     % propagation to the object
Im11 = double(imread('rt.bmp'));
F=LPMultIntensity(Im11(:,:,1),F);
F = LPForvard(FT2,F);                                       % propagation to the SH raster

npoints=cam_grid;                                           % SH sensor grid sampling 
ph = SH_phase(pitch,cam_size,foc_sh, npoints, lambda);      % SH sensor phase mask
F = LPMultPhase(ph,F);                                      % SH raster as phase mask 
F = LPRectAperture(lensarray_size,lensarray_size,0,0,0,F);  % pass the SH lenslets
F = LPForvard(foc_sh,F);                                    % propagation to the image plane

img=(LPIntensity(1,F)).^1;
imagesc(img) ;                                              % intensity in the sensor plane
colormap('gray');  
title('Sampled Shack-Hartmann pattern');

%% Reference 

Fr = LPBegin(cam_size,lambda,cam_grid);                     % initial plane wave
Fr = LPRectAperture(apert,apert,0,0,0,Fr);                  % Rrectangular Pupil plane

Fr = LPForvard(FT1*1,Fr);                                   % propagation to the object
Fr = LPForvard(FT2,Fr);                                     % propagation to the SH raster

npoints=cam_grid;                                           % SH sensor grid sampling 
ph = SH_phase(pitch,cam_size,foc_sh, npoints, lambda);      % SH sensor phase mask
Fr = LPMultPhase(ph,Fr);                                    % SH raster as phase mask 
Fr = LPRectAperture(lensarray_size,lensarray_size,0,0,0,Fr);% pass the SH lenslets
Fr = LPForvard(foc_sh,Fr);                                  % propagation to the image plane

ref=(LPIntensity(1,Fr)).^1;

figure(1),
subplot(221), imagesc(ref);colormap('gray'); title('Reference Shack-Hartmann pattern');
subplot(222), imagesc(img);colormap('gray'); title('Aberrated Shack-Hartmann pattern');

%% Wavefront reoncstruction
image=double(img);
ref=double(ref);

%% define phase unwrap method
unwrap_flag='Miguel';

[sx, sy] = ...
    fun_slope_finder_ribak(image, ref, pitch_px);

% display the slopes
subplot(223),imagesc(sx);title('x slope');xlabel('x');ylabel('y');colorbar;
subplot(224),imagesc(sy);title('y slope');xlabel('x');ylabel('y');colorbar;

% reconstruct wavefront
rflag = 2;                                                                 % choose reconstructor
wf_img = fun_reconstructor_ft_matrix(sx,sy,rflag);

figure(2),
subplot(211),imagesc(wf_img);title('Reconstructed wavefront');xlabel('x');ylabel('y');colorbar;
subplot(212),mesh(wf_img);title('Reconstructed wavefront');xlabel('x');ylabel('y');colorbar;

