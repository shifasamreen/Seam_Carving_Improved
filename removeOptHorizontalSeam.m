%finds the optimum horizontal seam to remove and removes it from image
%also returns the energy of the seam which can be used for other
%functions
function [updated_img, seamEnergy, min_seam_loc] = removeOptHorizontalSeam(energy, img)
    %perform dynamic programming to compute min horizontal seam
    M = zeros(size(img,1), size(img,2));
    M(:,1) = energy(:,1);

    r = size(img,1);
    c = size(img,2);

    if c==1
        M = energy;
    elseif r==1
        for i=1:r
            for j=2:c
                M(i,j) = energy(i,j) + M(i,j-1);        
            end
        end
    else
        for j=2:c
            for i=1:r
                if i-1 == 0
                    M(i,j) = energy(i,j) + min(M(i,j-1), M(i+1,j-1)); 
                elseif i == r
                    M(i,j) = energy(i,j) + min(M(i-1,j-1), M(i,j-1));    
                else
                    M(i,j) = energy(i,j) + min(M(i-1,j-1), min(M(i,j-1), M(i+1,j-1)));
                end        
            end
        end
    end

    %store the pixel locations for min seam
    min_seam_loc = zeros(c, 2);

    [v, I] = min(M(:,c));
    min_at_prev_col = I(1);
    min_seam_loc(c,:) = [c min_at_prev_col];
    
    if c~=1
        if r==1
            for j=2:c
                col = c - j + 1;
                
                min_seam_loc(col,:) = [col, min_at_prev_col];  
            end
        else
            for j=2:c
                col = c - j + 1;

                i = min_at_prev_col;
                
                if i-1 == 0
                    if M(i,col) <= M(i+1,col)
                        min_at_prev_col = i;
                    else
                        min_at_prev_col = i+1;
                    end 
                elseif i == r
                    if M(i-1,col) <= M(i,col)
                        min_at_prev_col = i-1;
                    else
                        min_at_prev_col = i;
                    end   
                else
                    if M(i-1,col) <= M(i,col) && M(i-1,col) <= M(i+1,col)
                        min_at_prev_col = i-1;
                    elseif M(i,col) <= M(i-1,col) && M(i,col) <= M(i+1,col)
                        min_at_prev_col = i;
                    else
                        min_at_prev_col = i+1;
                    end  
                end

                min_seam_loc(col,:) = [col, min_at_prev_col];                    
            end
        end
    end
    
    %create mask for pixels that are part of the seam
    mask = zeros(size(img,1), size(img,2));
    seamEnergy = 0;
    for i=1:size(min_seam_loc,1)
        row = min_seam_loc(i,2);
        col = min_seam_loc(i,1);
        
        mask(row, col) = 1;
        
        seamEnergy = seamEnergy + energy(row, col);
    end
    
    mask = logical(mask);
    mask = ~mask;
    
    %now create the updated img
    updated_img = zeros(size(img,1)-1, size(img,2), size(img,3));
    for j=1:size(mask,2)
        updated_img(:,j,1) = img(mask(:,j),j,1);
        updated_img(:,j,2) = img(mask(:,j),j,2);
        updated_img(:,j,3) = img(mask(:,j),j,3);
    end
end