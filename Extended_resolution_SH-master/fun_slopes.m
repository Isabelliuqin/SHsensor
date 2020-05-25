%% Finding the slopes with the measured image and reference image.
% sx, sy : slope arrays
% image, ref : input images to find the slope, square and the same size
% cutsize : wanted slope area
% q_cutoff: the size of filter
% Light Pipes is needed.
% sh_focal: the focal length of Shack Hartamnn lenslets
function [sx,sy,absftimage,sx_image,sy_image,sx_image_cut,sy_image_cut,sx_ref,sy_ref,USlope_x,USlope_y,USlope_x_ref,USlope_y_ref]=fun_slopes(image,ref,sh_focal,unwrap_flag,cutsize,q_cutoff,pixel_size,pitch)

cam_size=length(image);
%% Find slopes seperately
[sx_image,sy_image]=fun_slope_finder(image,q_cutoff);
[sx_ref,sy_ref,absftimage]=fun_slope_finder(ref,q_cutoff);


Len=cutsize;
sx_image_cut=sx_image((cam_size-Len)/2+1:(cam_size+Len)/2,(cam_size-Len)/2+1:(cam_size+Len)/2);
sy_image_cut=sy_image((cam_size-Len)/2+1:(cam_size+Len)/2,(cam_size-Len)/2+1:(cam_size+Len)/2);

sx_ref_cut=sx_ref((cam_size-Len)/2+1:(cam_size+Len)/2,(cam_size-Len)/2+1:(cam_size+Len)/2);
sy_ref_cut=sy_ref((cam_size-Len)/2+1:(cam_size+Len)/2,(cam_size-Len)/2+1:(cam_size+Len)/2);

% unwrap the slopes
if isequal(unwrap_flag,'LP')
    USlope_x=LPPhaseUnwrap(1,sx_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y=LPPhaseUnwrap(1,sy_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_x_ref=LPPhaseUnwrap(1,sx_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y_ref=LPPhaseUnwrap(1,sy_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    
elseif isequal(unwrap_flag,'DCT')
    USlope_x=fun_unwrappingPhase(sx_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y=fun_unwrappingPhase(sy_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_x_ref=fun_unwrappingPhase(sx_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y_ref=fun_unwrappingPhase(sy_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
  
elseif isequal(unwrap_flag,'matlab')
    USlope_x=unwrap(sx_image_cut,2)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y=unwrap(sy_image_cut,2)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_x_ref=unwrap(sx_ref_cut,2)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y_ref=unwrap(sy_ref_cut,2)/(2*pi*sh_focal/(pixel_size*pitch));

elseif isequal(unwrap_flag,'Goldstein')
    USlope_x=fun_GoldsteinUnwrap(sx_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y=fun_GoldsteinUnwrap(sy_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_x_ref=fun_GoldsteinUnwrap(sx_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y_ref=fun_GoldsteinUnwrap(sy_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
       
elseif isequal(unwrap_flag,'None')
    %To test no unwrap effects
    USlope_x=(sx_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y=(sy_image_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_x_ref=(sx_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
    USlope_y_ref=(sy_ref_cut)/(2*pi*sh_focal/(pixel_size*pitch));
end

delta_slope_x=USlope_x-USlope_x_ref;
delta_slope_y=USlope_y-USlope_y_ref;
%% cut the center matrix without no slope information
% Cut area size

sx=delta_slope_x;
sy=delta_slope_y;

sx=(sx-mean(mean(sx)));
sy=(sy-mean(mean(sy)));