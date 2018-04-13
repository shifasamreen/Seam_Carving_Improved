%reduces an image to required size
function removed_img = removeObject(img, mask_remove, mask_maintain, type)  
    profile on;
    mask_remove = (mask_remove - mask_maintain)>0;
    mask_maintain = logical(mask_maintain);
    
    stats = regionprops('table',mask_remove,'BoundingBox');
    bb = stats.BoundingBox;    
    
    for k=1:size(bb,1)
        x = floor(bb(k,1));
        y = floor(bb(k,2));
        width = floor(bb(k,3));
        height = floor(bb(k,4));
        
        curr_mask = zeros(size(mask_remove));
        curr_mask(y:y+height, x:x+width) = mask_remove(y:y+height, x:x+width);
        
        total_pixels_threshold = 0.001*sum(sum(curr_mask == 1));
        if height > width
            %remove vertical seams
            done = 0;
            while ~done
                energy = gradientEnergy(img);
                energy = energy + (-1000000*curr_mask);
                energy = energy + (1000000000*mask_maintain);
                
                if strcmp(type, 'BE')
                    [img, seamEnergy, min_seam_loc] = removeOptVerticalSeam(energy, img);
                else
                    [img, seamEnergy, min_seam_loc] = removeOptVerticalSeamFE(energy, img);
                end
                
                %create mask for pixels that are part of the seam
                new_mask = zeros(size(curr_mask,1), size(curr_mask,2));
                for i=1:size(min_seam_loc,1)
                    row = min_seam_loc(i,1);
                    col = min_seam_loc(i,2);

                    new_mask(row, col) = 1;
                end

                new_mask = logical(new_mask);
                new_mask = ~new_mask;

                %now create the updated mask
                mask2 = zeros(size(curr_mask,1), size(curr_mask,2)-1);
                mask3 = zeros(size(curr_mask,1), size(curr_mask,2)-1);
                mask4 = zeros(size(curr_mask,1), size(curr_mask,2)-1);
                for i=1:size(curr_mask,1)
                    mask2(i,:) = curr_mask(i,new_mask(i,:));
                    mask3(i,:) = mask_remove(i,new_mask(i,:));
                    mask4(i,:) = mask_maintain(i,new_mask(i,:));
                end
                 
                curr_mask = mask2;
                mask_remove = mask3;
                mask_maintain = mask4;
                
                if sum(sum(curr_mask == 1)) < total_pixels_threshold
                   done = 1; 
                end
            end
        else
            %remove horizontal seams
            done = 0;
            while ~done
                energy = gradientEnergy(img);
                energy = energy + (-1000000*curr_mask);
                energy = energy + (1000000000*mask_maintain);
                
                if strcmp(type, 'BE')
                    [img, seamEnergy, min_seam_loc] = removeOptHorizontalSeam(energy, img);
                else
                    [img, seamEnergy, min_seam_loc] = removeOptHorizontalSeamFE(energy, img);
                end
                
                
                %create mask for pixels that are part of the seam
                new_mask = zeros(size(curr_mask,1), size(curr_mask,2));
                for i=1:size(min_seam_loc,1)
                    row = min_seam_loc(i,2);
                    col = min_seam_loc(i,1);

                    new_mask(row, col) = 1;
                end

                new_mask = logical(new_mask);
                new_mask = ~new_mask;

                %now create the updated img
                mask2 = zeros(size(curr_mask,1)-1, size(curr_mask,2));
                mask3 = zeros(size(curr_mask,1)-1, size(curr_mask,2));
                mask4 = zeros(size(curr_mask,1)-1, size(curr_mask,2));
                for j=1:size(curr_mask,2)
                    mask2(:,j) = curr_mask(new_mask(:,j),j);
                    mask3(:,j) = mask_remove(new_mask(:,j),j);
                    mask4(:,j) = mask_maintain(new_mask(:,j),j);
                end
                
                curr_mask = mask2;
                mask_remove = mask3;
                mask_maintain = mask4;
                
                if sum(sum(curr_mask == 1)) < total_pixels_threshold
                   done = 1; 
                end
            end
        end
    end
    
    removed_img = img;
    profile viewer;
end