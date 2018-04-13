%computes transport map and choice bit map while computing optimal
%seam ordering when resizing a given image. 0 is vertical seam and 1 is
%horizontal seam
function [T_map, T_choice_map] = optSeamOrderingTMap(output_size, img)
    n = size(img,1);
    m = size(img,2);
    
    r = output_size(1);
    c = output_size(2);
    
    T_map = zeros(r+1, c+1, 'double');
    T_choice_map = ones(size(T_map))*-1;
    T_choice_map(1,1) = -1;
    
    
    %now with top row of T_map
    updated_img = img;
    for i=2:size(T_map,1)
        energy = gradientEnergy(updated_img);
        [updated_img, seamEnergy] = removeOptHorizontalSeam(energy, updated_img);
        
        T_map(i,1) = T_map(i-1,1) + seamEnergy;
        T_choice_map(i,1) = 1;
    end
    
    %start with left column of T_map
    updated_img = img;
    for j=2:size(T_map,2)
        energy = gradientEnergy(updated_img);
        [updated_img, seamEnergy] = removeOptVerticalSeam(energy, updated_img);
        
        T_map(1,j) = T_map(1, j-1) + seamEnergy;
        T_choice_map(1,j) = 0;
    end
    
    
    %now for the rest of T_map we need to remove on vertical and horizontal
    %seam
    energy = gradientEnergy(img);
    [img_hor, seamEnergy] = removeOptHorizontalSeam(energy, img);
    
    energy = gradientEnergy(img);
    [img_ver, seamEnergy] = removeOptVerticalSeam(energy, img);
    
    
    %now start with the rest of T_map
    for i=2:size(T_map,1)
        update_img_hor = img_hor;
        update_img_ver = img_ver;
        for j=2:size(T_map,2)
            e_ver = gradientEnergy(update_img_ver);
            [img_hor_removed, seamHorEnergy] = removeOptHorizontalSeam(e_ver, update_img_ver);
            [update_img_hor, seamVerEnergy] = removeOptVerticalSeam(gradientEnergy(update_img_hor), update_img_hor);
            
            if (T_map(i-1,j) + seamHorEnergy) <= (T_map(i,j-1) + seamVerEnergy)
                T_map(i,j) = T_map(i-1,j) + seamHorEnergy;
                T_choice_map(i,j) = 1;
            else
                T_map(i,j) = T_map(i,j-1) + seamVerEnergy;
                T_choice_map(i,j) = 0;
            end
            
            update_img_ver = removeOptVerticalSeam(e_ver, update_img_ver);
        end
        
        [img_ver, seamVerEnergy] = removeOptHorizontalSeam(gradientEnergy(img_ver), img_ver);
        [img_hor, seamVerEnergy] = removeOptHorizontalSeam(gradientEnergy(img_hor), img_hor);
    end
end