%   [sx_img, sy_img, sx_ref, sy_ref, sx_sample, sy_sample, samplegrid] = ...
%       fun_slope_finder_ribak(sh_img, sh_ref, pitch)
%
%   Find the slope from Shack Hartmann pattern with direct demodulation from Erez Ribak
%
%   pitch           - pixels between HS spots, in this example equal in x and y
%   sh_img, sh_ref  - the object SH sensor pattern and reference pattern
%
%   Demodulate image array (im) of Hartmann-Shack spots at known pitch (pitch) 
%   Outputs: idx, idy are complex arrays whose phases are the x and y gradients
%   Upon first run (li==0) perform demodulation and save reference arrays iex, iey
% 
%   Each image is first multiplied by phasors of the pitch frequency, then smoothed
%   at 1/2, 1/4, 1/8,,, pitch (usualy it's possible to comment out the 1/8 steps). 
%   Smoothing is performed by shifting the array both ways in pitch fractions and 
%   summing with the original array, then repeating in orthogonal direction.
% 
%   This software is free to copy and use, under the single condition that any
%   publication using it, or its modification, includes a reference to the paper
%   A Talmi and E N Ribak: Direct demodulation of Hartmann-Shack patterns, Journal 
%   of the Optical Society of America A 21, 632-9 (2004).

function [sx_img, sy_img, sx_ref, sy_ref, sx_sample, sy_sample, samplegrid, sx_img_n, sy_img_n] = fun_slope_finder_ribak(sh_img, sh_ref, pitch_px)
    disp('Calculating slopes by function: fun_slope_finder_ribak...');
    
    im = double (sh_img);                                                 % read file
    sr = size (im);                                                       % size of input image array of HS spots
    rp2 = round (pitch_px/2); rp4 = round (pitch_px/4); rp8 = round (pitch_px/8);  % smoothing step sizes

    samplegrid = 2*round ((sr/pitch_px - [1 1]));                                % # of points to sample

    i = sqrt (-1); pi = acos (-1);                                        % just in case
    rulex = i * (1:sr(2)) * 2 * pi / pitch_px;                              % linear phase along x
    ruley = i * (1:sr(1)).' * 2 * pi / pitch_px;                            % ditto along y
    
%   iex = 1; iey = 1;                                                     % reference phasor arrays, initially 1
%%  pre-allocation
    sx_sample = zeros(samplegrid);
    sy_sample = zeros(samplegrid);
    
    %% Calculate sx for image
    idx = im .* (ones (sr(1),1) * exp (rulex));                           % add complex phase to image along x
    idx = 2 * idx + circshift (idx, [rp2 0]) + circshift (idx, [-rp2 0]); % smooth at half pitch, y
    idx = 2 * idx + circshift (idx, [rp4 0]) + circshift (idx, [-rp4 0]); % smooth at quarter pitch
    idx = 2 * idx + circshift (idx, [rp8 0]) + circshift (idx, [-rp8 0]); % smooth at one eighth pitch
    idx = 2 * idx + circshift (idx, [0 rp2]) + circshift (idx, [0 -rp2]); % smooth at half pitch, x
    idx = 2 * idx + circshift (idx, [0 rp4]) + circshift (idx, [0 -rp4]); % smooth at quarter pitch
    idx = 2 * idx + circshift (idx, [0 rp8]) + circshift (idx, [0 -rp8]); % smooth at one eighth pitch

    %% Calculate sy for image  
    idy = im .* (exp (ruley) * ones (1, sr(2)));                          % add complex phase to image along y
    idy = 2 * idy + circshift (idy, [rp2 0]) + circshift (idy, [-rp2 0]); % smooth at half pitch, y
    idy = 2 * idy + circshift (idy, [rp4 0]) + circshift (idy, [-rp4 0]); % smooth at quarter pitch
    idy = 2 * idy + circshift (idy, [rp8 0]) + circshift (idy, [-rp8 0]); % smooth at one eighth pitch
    idy = 2 * idy + circshift (idy, [0 rp2]) + circshift (idy, [0 -rp2]); % smooth at half pitch, x
    idy = 2 * idy + circshift (idy, [0 rp4]) + circshift (idy, [0 -rp4]); % smooth at quarter pitch
    idy = 2 * idy + circshift (idy, [0 rp8]) + circshift (idy, [0 -rp8]); % smooth at one eighth pitch
       
    iex = idx;                                                            % save sx for image
    iey = idy;                                                            % save sy for image
    sx_img = angle (iex);
    sy_img = angle (iey);
    
    sx_img_n = sx_img;
    sy_img_n = sy_img;
    
    if isempty(sh_ref)  % if there is no reference, we only calculate the image 
        sx_ref = zeros(sr);
        sy_ref = zeros(sr);        
    else
        im = double (sh_ref); 
        %% Calculate sx for ref
        idx = im .* (ones (sr(1),1) * exp (rulex));                           % add complex phase to image along x
        idx = 2 * idx + circshift (idx, [rp2 0]) + circshift (idx, [-rp2 0]); % smooth at half pitch, y
        idx = 2 * idx + circshift (idx, [rp4 0]) + circshift (idx, [-rp4 0]); % smooth at quarter pitch
        idx = 2 * idx + circshift (idx, [rp8 0]) + circshift (idx, [-rp8 0]); % smooth at one eighth pitch
        idx = 2 * idx + circshift (idx, [0 rp2]) + circshift (idx, [0 -rp2]); % smooth at half pitch, x
        idx = 2 * idx + circshift (idx, [0 rp4]) + circshift (idx, [0 -rp4]); % smooth at quarter pitch
        idx = 2 * idx + circshift (idx, [0 rp8]) + circshift (idx, [0 -rp8]); % smooth at one eighth pitch

        %% Calculate sy for ref  
        idy = im .* (exp (ruley) * ones (1, sr(2)));                          % add complex phase to image along y
        idy = 2 * idy + circshift (idy, [rp2 0]) + circshift (idy, [-rp2 0]); % smooth at half pitch, y
        idy = 2 * idy + circshift (idy, [rp4 0]) + circshift (idy, [-rp4 0]); % smooth at quarter pitch
        idy = 2 * idy + circshift (idy, [rp8 0]) + circshift (idy, [-rp8 0]); % smooth at one eighth pitch
        idy = 2 * idy + circshift (idy, [0 rp2]) + circshift (idy, [0 -rp2]); % smooth at half pitch, x
        idy = 2 * idy + circshift (idy, [0 rp4]) + circshift (idy, [0 -rp4]); % smooth at quarter pitch
        idy = 2 * idy + circshift (idy, [0 rp8]) + circshift (idy, [0 -rp8]); % smooth at one eighth pitch

        sx_ref = angle (idx);
        sy_ref = angle (idy);
    
        iex = iex .* conj(idx);                                               % remove reference phase
        iey = iey .* conj(idy);                                               % remove reference phase
        
        sx_img = angle (iex);
        sy_img = angle (iey);
        
    end
%% resize the wavefront - comment due to time consuming    

     tempx = imresize(iex(rp2:end-rp2+1,rp2:end-rp2+1),samplegrid);          % sample points
     tempy = imresize(iey(rp2:end-rp2+1,rp2:end-rp2+1),samplegrid);          % sample points
%     a = [tempx(:)' tempy(:)'];                                              % x, y gradients into linear array
%     
     sx_sample = angle(tempx);
     sy_sample = angle(tempy);
end
