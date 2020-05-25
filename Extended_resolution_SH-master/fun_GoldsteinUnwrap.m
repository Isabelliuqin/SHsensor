function unwrap_phase = fun_GoldsteinUnwrap(phase)

%Phase image
unwrap_phase=zeros(size(phase));               %Zero starting matrix for unwrapped phase
unwrapped_binary=zeros(size(phase));           %Binary image to mark unwrapped pixels
mag=zeros(size(phase));
mask=ones(size(phase)); 
mag_max = 0;
%% Compute the residues
residue_charge = PhaseResidues_r1(phase, mask); % Calculate phase residues (Does not use mask)
% figure; imagesc(residue_charge), colormap(gray), axis square, axis off, title('GS Phase residues (charged)'); colorbar;

%% Compute the branch cuts
max_box_radius=floor(length(residue_charge)/2);  % Maximum search box radius (pixels)
if(~exist('max_box_radius','var'))
  max_box_radius=4;  % Maximum search box radius (pixels)
end
% BranchCuts() ignores residues with mask == 0, so keep the entire mask == 1
branch_cuts = BranchCuts_r1(residue_charge, max_box_radius, mask); % Place branch cuts

% figure; imagesc(branch_cuts),    colormap(gray), axis square, axis off, title('GS Branch cuts'); colorbar;

mask(branch_cuts) = 0;  % Now need to mask off branch cut points, in order to avoid an error in FloodFill
m_mag = mag.*mask; % Mask off magnitude == 0 points, so that they are not chosen for the starting point

%% Manually (default) or automatically identify starting seed point 
% if(0)  % Chose starting point interactively
%   im_phase_quality = im_mag1;
%   minp = im_phase_quality(2:end-1, 2:end-1); minp = min(minp(:));
%   maxp = im_phase_quality(2:end-1, 2:end-1); maxp = max(maxp(:));
%   figure; imagesc(im_phase_quality,[minp maxp]), colormap(gray), colorbar, axis square, axis off; title('Phase quality map');
%   %uiwait(msgbox('Select known true phase reference phase point. Black = high quality phase; white = low quality phase.','Phase reference point','modal'));
%   uiwait(msgbox('Select known true phase reference phase point. White = high magnitude; Black = low magnitude.','Phase reference point','modal'));
%   [xpoint,ypoint] = ginput(1);        %Select starting point for the guided floodfill algorithm
%   colref = round(xpoint);
%   rowref = round(ypoint);
%   close;                              %Close the figure;
% else   % Chose starting point = max. intensity
  [r_dim, c_dim]=size(phase);
  m_mag(1,:) = 0;                     %Set magnitude of border pixels to 0, so that they are not used for the reference
  m_mag(r_dim,:) = 0;
  m_mag(:,1) = 0;
  m_mag(:,c_dim) = 0;
  [rowrefn,colrefn] = find(m_mag >= 0.9*mag_max);
  rowref = rowrefn(1);                  %Choose the 1st point for a reference (known good value)
  colref = colrefn(1);                  %Choose the 1st point for a reference (known good value)
% end

%% Unwrap
if(exist('rowref','var'))
  unwrap_phase = FloodFill_r1(phase, mag, branch_cuts, mask, colref, rowref); % Flood fill phase unwrapping
else
  unwrap_phase = FloodFill_r1(phase, mag, branch_cuts, mask); % Flood fill phase unwrapping
end
% Display results
% figure; imagesc(unwrap_phase), colormap(gray), colorbar, axis square, axis off, title('GS Unwrapped phase');
