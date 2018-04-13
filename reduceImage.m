%reduces an image to required size
function reduced_img = reduceImage(output_size, img)
   profile on;
    n = size(img,1);
    m = size(img,2);
    
    n_desired = output_size(1);
    m_desired = output_size(2);
    
    desired_size = [n-n_desired, m-m_desired];
    
    [T_map, T_choice_map] = optSeamOrderingTMap(desired_size, img);
    
    %traverse choice map and add seams in optimal ordering
    r = size(T_choice_map, 1);
    c = size(T_choice_map, 2);
    
    k = desired_size(1) + desired_size(2);
    
    for i=1:k
        energy = gradientEnergy(img);
         
        if(T_choice_map(r,c) == 0)
        	[img, seamEnergy] = removeOptVerticalSeam(energy, img);
            c = c - 1;
        else
            [img, seamEnergy] = removeOptHorizontalSeam(energy, img);
            r = r - 1;
        end
    end
    
    reduced_img = img;
    profile viewer;
end