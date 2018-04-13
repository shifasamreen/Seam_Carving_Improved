%finds the optimum horizontal seam to remove and removes it from image
%also returns the energy of the seam which can be used for other
%functions
function [updated_img, updated_FX, updated_FY] = addOptHorizontalSeamGD(FX, FY, img, min_seam_loc)
    %perform dynamic programming to compute min horizontal seam
%     M = zeros(size(FX,1), size(FX,2));
%     M(:,1) = energy(:,1);
% 
%     r = size(FX,1);
%     c = size(FX,2);
% 
%     for i=1:r
%         for j=2:c
%             if i-1 == 0
%                 M(i,j) = energy(i,j) + min(M(i,j-1), M(i+1,j-1)); 
%             elseif i == r
%                 M(i,j) = energy(i,j) + min(M(i-1,j-1), M(i,j-1));    
%             else
%                 M(i,j) = energy(i,j) + min(M(i-1,j-1), min(M(i,j-1), M(i+1,j-1)));
%             end        
%         end
%     end
% 
%     %store the pixel locations for min seam
%     min_seam_loc = zeros(c, 2);
% 
%     [v, I] = min(M(:,c));
%     min_at_prev_col = I(1);
%     min_seam_loc(c,:) = [c min_at_prev_col];
% 
%     for j=2:c
%         col = c - j + 1;
% 
%         i = min_at_prev_col;
% 
%         if i-1 == 0
%             if M(i,col) <= M(i+1,col)
%                 min_at_prev_col = i;
%             else
%                 min_at_prev_col = i+1;
%             end 
%         elseif i == r
%             if M(i-1,col) <= M(i,col)
%                 min_at_prev_col = i-1;
%             else
%                 min_at_prev_col = i;
%             end   
%         else
%             if M(i-1,col) <= M(i,col) && M(i-1,col) <= M(i+1,col)
%                 min_at_prev_col = i-1;
%             elseif M(i,col) <= M(i-1,col) && M(i,col) <= M(i+1,col)
%                 min_at_prev_col = i;
%             else
%                 min_at_prev_col = i+1;
%             end  
%         end
% 
%         min_seam_loc(col,:) = [col, min_at_prev_col];                    
%     end
    
    %create mask for pixels that are part of the seam
    mask = zeros(size(FX,1), size(FX,2));
    seamEnergy = 0;
    for i=1:size(min_seam_loc,1)
        row = min_seam_loc(i,2);
        col = min_seam_loc(i,1);
        
        mask(row, col) = 1;
    end
    
    mask = logical(mask);
    
    %now create the updated FX, FY
    updated_FX = zeros(size(FX,1)+1, size(FX,2), size(img,3));
    updated_FY = zeros(size(FY,1)+1, size(FY,2), size(img,3));
    updated_img = zeros(size(img,1)+1, size(img,2), size(img,3));
    for j=1:size(mask,2)
        i = find(mask(:,j) == 1);
        
        if i == size(mask,1)
            i = i - 1;
        end
        
        avg_s = (img(i,j,1) + img(i+1,j,1))/2;
        updated_img(:,j,1) = [img(1:i,j,1); avg_s; img(i+1:end,j,1)];
        
        avg_s = (img(i,j,2) + img(i+1,j,2))/2;
        updated_img(:,j,2) = [img(1:i,j,2); avg_s; img(i+1:end,j,2)];
        
        avg_s = (img(i,j,3) + img(i+1,j,3))/2;
        updated_img(:,j,3) = [img(1:i,j,3); avg_s; img(i+1:end,j,3)];
        
        
        avg_s = (FX(i,j,1) + FX(i+1,j,1))/2;
        updated_FX(:,j,1) = [FX(1:i,j,1); avg_s; FX(i+1:end,j,1)];
        
        avg_s = (FX(i,j,2) + FX(i+1,j,2))/2;
        updated_FX(:,j,2) = [FX(1:i,j,2); avg_s; FX(i+1:end,j,2)];
        
        avg_s = (FX(i,j,3) + FX(i+1,j,3))/2;
        updated_FX(:,j,3) = [FX(1:i,j,3); avg_s; FX(i+1:end,j,3)];
        
        
        avg_s = (FY(i,j,1) + FY(i+1,j,1))/2;
        updated_FY(:,j,1) = [FY(1:i,j,1); avg_s; FY(i+1:end,j,1)];
        
        avg_s = (FY(i,j,2) + FY(i+1,j,2))/2;
        updated_FY(:,j,2) = [FY(1:i,j,2); avg_s; FY(i+1:end,j,2)];
        
        avg_s = (FY(i,j,3) + FY(i+1,j,3))/2;
        updated_FY(:,j,3) = [FY(1:i,j,3); avg_s; FY(i+1:end,j,3)];
        
    end
end