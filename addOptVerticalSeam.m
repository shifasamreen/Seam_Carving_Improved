%finds the optimum vertical seam to remove and adds its avg to the image
%also returns the energy of the seam which can be used for other
%functions
function [updated_img] = addOptVerticalSeam(img, min_seam_loc)
%     %perform dynamic programming to compute min vertical seam
%     M = zeros(size(img,1), size(img,2));
%     M(1,:) = energy(1,:);
% 
%     r = size(img,1);
%     c = size(img,2);
% 
%     for i=2:r
%         for j=1:c
%             if j-1 == 0
%                 M(i,j) = energy(i,j) + min(M(i-1,j), M(i-1,j+1)); 
%             elseif j == c
%                 M(i,j) = energy(i,j) + min(M(i-1,j-1), M(i-1,j));    
%             else
%                 M(i,j) = energy(i,j) + min(M(i-1,j-1), min(M(i-1,j), M(i-1,j+1)));
%             end        
%         end
%     end
% 
%     %store the pixel locations for min seam
%     min_seam_loc = zeros(r, 2);
% 
%     [v, I] = min(M(r,:));
%     min_at_prev_row = I(1);
%     min_seam_loc(r,:) = [r min_at_prev_row];
%     
%     for i=2:r
%         row = r - i + 1;
% 
%         j = min_at_prev_row;
% 
%         if j-1 == 0
%             if M(row,j) <= M(row,j+1)
%                 min_at_prev_row = j;
%             else
%                 min_at_prev_row = j+1;
%             end 
%         elseif j == c
%             if M(row,j-1) <= M(row,j)
%                 min_at_prev_row = j-1;
%             else
%                 min_at_prev_row = j;
%             end   
%         else
%             if M(row,j-1) <= M(row,j) && M(row,j-1) <= M(row,j+1)
%                 min_at_prev_row = j-1;
%             elseif M(row,j) <= M(row,j-1) && M(row,j) <= M(row,j+1)
%                 min_at_prev_row = j;
%             else
%                 min_at_prev_row = j+1;
%             end  
%         end
% 
%         min_seam_loc(row,:) = [row, min_at_prev_row];                    
%     end
    
    %create mask for pixels that are part of the seam
    mask = zeros(size(img,1), size(img,2));
    seamEnergy = 0;
    for i=1:size(min_seam_loc,1)
        row = min_seam_loc(i,1);
        col = min_seam_loc(i,2);
        
        mask(row, col) = 1;
    end
    
    mask = logical(mask);
    
    %now create the updated img
    updated_img = zeros(size(img,1), size(img,2)+1, size(img,3));
    for i=1:size(mask,1)
        j = find(mask(i,:) == 1);
        
        if j == size(mask,2)
            j = j - 1;
        end
        
        avg_s = (img(i,j,1) + img(i,j+1,1))/2;
        updated_img(i,:,1) = [img(i,1:j,1), avg_s, img(i,j+1:end,1)];
        
        avg_s = (img(i,j,2) + img(i,j+1,2))/2;
        updated_img(i,:,2) = [img(i,1:j,2), avg_s, img(i,j+1:end,2)];
        
        avg_s = (img(i,j,3) + img(i,j+1,3))/2;
        updated_img(i,:,3) = [img(i,1:j,3), avg_s, img(i,j+1:end,3)];
    end
end