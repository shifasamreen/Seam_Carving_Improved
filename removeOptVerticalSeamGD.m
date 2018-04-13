%finds the optimum vertical seam to remove and removes it from image
%also returns the energy of the seam which can be used for other
%functions
function [updated_img, updated_FX, updated_FY, seamEnergy, min_seam_loc] = removeOptVerticalSeamGD(energy, FX, FY, img)
    %perform dynamic programming to compute min vertical seam
    M = zeros(size(FX,1), size(FX,2));
    M(1,:) = energy(1,:);

    r = size(FX,1);
    c = size(FX,2);

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
    
    %now create the updated FX, FY, img
    updated_FX = zeros(size(FX,1), size(FX,2)-1, size(img,3));
    updated_FY = zeros(size(FY,1), size(FY,2)-1, size(img,3));
    updated_img = zeros(size(img,1), size(img,2)-1, size(img,3));
    for i=1:size(mask,1)
%         updated_FX(i,:) = FX(i,mask(i,:));
%         
%         updated_FY(i,:) = FY(i,mask(i,:));
%         
%         updated_img(i,:) = img(i,mask(i,:));

        updated_img(i,:,1) = img(i,mask(i,:),1);
        updated_img(i,:,2) = img(i,mask(i,:),2);
        updated_img(i,:,3) = img(i,mask(i,:),3);
        
        updated_FX(i,:,1) = FX(i,mask(i,:),1);
        updated_FX(i,:,2) = FX(i,mask(i,:),2);
        updated_FX(i,:,3) = FX(i,mask(i,:),3);
        
        updated_FY(i,:,1) = FY(i,mask(i,:),1);
        updated_FY(i,:,2) = FY(i,mask(i,:),2);
        updated_FY(i,:,3) = FY(i,mask(i,:),3);
    end
end