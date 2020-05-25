% Shack-Hartmann sensor model
% Gleb Vdovin May 2015


function[ph] = SH_phase(pitch,D,F, npoints, lambda)

% pitch is the pitch of square microlens array
% D is the size of the whole grid
% F is the focal length of the microlenses 
% npoints is the grid sampling, the grid is npoints x npoints
% npoints should be even
% lambda is the wavelength

wave_num= 2*pi/lambda;
dx=D/(npoints - 1.); % square grid, dy=dx, so we use only dx
npitch=floor(D/pitch/2.+2.);

if dx > abs(F*lambda/2/pitch) % condition for correct sampling
       sprintf('SH_phase: The sampling is too rough!!')
end

ph=zeros(npoints);

n2=npoints/2+1;  %Central point,  zero coordinate

for ipx=-npitch: npitch
    xmin=(ipx-0.5)*pitch;
    xc=(ipx)*pitch;
    xmax=(ipx+0.5)*pitch;
    
    for ipy=-npitch: npitch
    ymin=(ipy-0.5)*pitch;
    yc=(ipy)*pitch;
    ymax=(ipy+0.5)*pitch;

    ixmin=floor(xmin/dx)+n2-2;  % x boundaries for the square to be filled, little bit bigger than necessary
    if ixmin < 1  
        ixmin = 1  ;
    end
    if ixmin > npoints  
        ixmin = npoints;  
    end
    
    ixmax=floor(xmax/dx)+n2+2;
    if ixmax < 1  
        ixmax = 1  ;
    end
    if ixmax > npoints  
        ixmax = npoints ; 
    end
for i=ixmin:ixmax
    x=(i-n2)*dx; % x coordinate 
    
    iymin=floor(ymin/dx)+n2-2;  % x boundaries for the square to be filled, little bit bigger than necessary
    if iymin < 1  
        iymin = 1  ;
    end
    if iymin > npoints  
        iymin = npoints;  
    end
    
    iymax=floor(ymax/dx)+n2+2;
    if iymax < 1  
        iymax = 1  ;
    end
    if iymax > npoints  
        iymax = npoints;  
    end
    
    for j=iymin:iymax
      y=(j-n2)*dx; % y coordinate  
      
      if x <=xmax && x >= xmin && y <=ymax && y >= ymin
          r2=(x-xc)^2+(y-yc)^2;
          ph(i,j)= -wave_num*r2/2/F;
          
      end
      
      
    end
end
    end
end



end
