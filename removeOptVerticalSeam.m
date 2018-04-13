%finds the optimum vertical seam to remove and removes it from image
%also returns the energy of the seam which can be used for other
%functions
function [updated_img, seamEnergy, min_seam_loc] = removeOptVerticalSeam(energy, img)
    %perform dynamic programming to compute min vertical seam
    M = zeros(size(img,1), size(img,2));
    M(1,:) = energy(1,:);

    r = size(img,1);
    c = size(img,2);

    if r==1
        M = energy;
    elseif c==1
        for i=2:r
            for j=1:c
                M(i,j) = energy(i,j) + M(i-1,j);        
            end
        end
    else
        for i=2:r
            for j=1:c
                if j-1 == 0
                    M(i,j) = energy(i,j) + min(M(i-1,j), M(i-1,j+1)); 
                elseif j == c
                    M(i,j) = energy(i,j) + min(M(i-1,j-1), M(i-1,j));    
                else
                    M(i,j) = energy(i,j) + min(M(i-1,j-1), min(M(i-1,j), M(i-1,j+1)));
                end        
            end
        end
    end

    %store the pixel locations for min seam
    min_seam_loc = zeros(r, 2);

    [v, I] = min(M(r,:));
    min_at_prev_row = I(1);
    min_seam_loc(r,:) = [r min_at_prev_row];
    
    if r~=1
        if c==1
            for i=2:r
                row = r - i + 1;
                min_seam_loc(row,:) = [row, min_at_prev_row];  
            end
        else
            for i=2:r
                row = r - i + 1;

                j = min_at_prev_row;
                  
                if j-1 == 0
                    if M(row,j) <= M(row,j+1)
                        min_at_prev_row = j;
                    else
                        min_at_prev_row = j+1;
                    end 
                elseif j == c
                    if M(row,j-1) <= M(row,j)
                        min_at_prev_row = j-1;
                    else
                        min_at_prev_row = j;
                    end   
                else
                    if M(row,j-1) <= M(row,j) && M(row,j-1) <= M(row,j+1)
                        min_at_prev_row = j-1;
                    elseif M(row,j) <= M(row,j-1) && M(row,j) <= M(row,j+1)
                        min_at_prev_row = j;
                    else
                        min_at_prev_row = j+1;
                    end  
                end

                min_seam_loc(row,:) = [row, min_at_prev_row];                    
            end
        end
    end
    
    %create mask for pixels that are part of the seam
    mask = zeros(size(img,1), size(img,2));
    seamEnergy = 0;
    for i=1:size(min_seam_loc,1)
        row = min_seam_loc(i,1);
        col = min_seam_loc(i,2);
        
        mask(row, col) = 1;
        
        seamEnergy = seamEnergy + energy(row, col);
    end
    
    mask = logical(mask);
    mask = ~mask;
    
    %now create the updated img
    updated_img = zeros(size(img,1), size(img,2)-1, size(img,3));
    for i=1:size(mask,1)
        updated_img(i,:,1) = img(i,mask(i,:),1);
        updated_img(i,:,2) = img(i,mask(i,:),2);
        updated_img(i,:,3) = img(i,mask(i,:),3);
    end
end