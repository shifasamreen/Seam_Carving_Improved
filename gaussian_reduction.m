%reduces an image to required size starting with vertical then horizontal
function reduced_img = gaussian_reduction(output_size, img, mask_maintain)
profile on;
    n = size(img,1);
    m = size(img,2);
    
    n_desired = output_size(1);
    m_desired = output_size(2);
    
    desired_size = [n-n_desired, m-m_desired];
   
    r = n-n_desired;
    c = m-m_desired;
    
    k = desired_size(1) + desired_size(2);
    
    for i=1:k
        energy = gradientEnergy(img)+ (10000000000*mask_maintain);
         
        if(c ~= 0)
        	[img, seamEnergy, min_seam_loc] = removeOptVerticalSeam(energy, img);
                
            %create mask for pixels that are part of the seam
            new_mask = zeros(size(mask_maintain,1), size(mask_maintain,2));
            for q=1:size(min_seam_loc,1)
                row = min_seam_loc(q,1);
                col = min_seam_loc(q,2);

                new_mask(row, col) = 1;
            end

            new_mask = logical(new_mask);
            new_mask = ~new_mask;

            %now create the updated mask
            mask2 = zeros(size(mask_maintain,1), size(mask_maintain,2)-1);
            for t=1:size(mask_maintain,1)
                mask2(t,:) = mask_maintain(t,new_mask(t,:));
            end
            mask_maintain = mask2;
            
            c = c - 1;
        else
            [img, seamEnergy, min_seam_loc] = removeOptHorizontalSeam(energy, img);
                
            %create mask for pixels that are part of the seam
            new_mask = zeros(size(mask_maintain,1), size(mask_maintain,2));
            for q=1:size(min_seam_loc,1)
                row = min_seam_loc(q,2);
                col = min_seam_loc(q,1);

                new_mask(row, col) = 1;
            end

            new_mask = logical(new_mask);
            new_mask = ~new_mask;

            %now create the updated img
            mask2 = zeros(size(mask_maintain,1)-1, size(mask_maintain,2));
            for j=1:size(mask_maintain,2)
                mask2(:,j) = mask_maintain(new_mask(:,j),j);
            end

            mask_maintain = mask2;
            
            r = r - 1;
          
        end
    end
    
    reduced_img = img;
    profile viewer;
end