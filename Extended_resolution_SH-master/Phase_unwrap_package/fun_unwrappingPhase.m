%% Phase unwrap DCT method
function unwrap_phase = fun_unwrappingPhase(phase)

size_d = size(phase);

for ii = 1:size_d(1)-1
    for jj = 1:size_d(2)
        diff_x(ii,jj) = phase(ii+1,jj) - phase(ii,jj);
        if(diff_x(ii,jj)>pi)
            diff_x(ii,jj) = diff_x(ii,jj)-2*pi;
        elseif(diff_x(ii,jj)<-pi)
            diff_x(ii,jj) = diff_x(ii,jj)+2*pi;
        end
    end
end

for ii = 1:size_d(1)
    for jj = 1:size_d(2)-1
        diff_y(ii,jj) = phase(ii,jj+1) - phase(ii,jj);
        if(diff_y(ii,jj)>pi)
            diff_y(ii,jj) = diff_y(ii,jj)-2*pi;
        elseif(diff_y(ii,jj)<-pi)
            diff_y(ii,jj) = diff_y(ii,jj)+2*pi;
        end        
    end
end

diff_xx = diff_x;
diff_xx(size_d(1),:) = 0;
diff_yy = diff_y;
diff_yy(:,size_d(2)) = 0;

diff_x1x(2:size_d(1),:) = diff_x(1:size_d(1)-1,:);
diff_x1x(1,:) = 0;
diff_y1y(:,2:size_d(2)) = diff_y(:,1:size_d(2)-1);
diff_y1y(:,1) = 0;

p = diff_xx + diff_yy - diff_x1x - diff_y1y;

dp = dct2(p);

for ii = 1:size_d(1)
    for jj = 1:size_d(2)
        if((ii == 1)&&(jj == 1)) 
            fanp(ii,jj) = dp(1,1);
        else
            fanp(ii,jj) = dp(ii,jj)/(2*(cos(pi*(ii-1)/size_d(1)) + cos(pi*(jj-1)/size_d(2)) - 2));
        end;
    end
end

unwrap_phase = idct2(fanp);