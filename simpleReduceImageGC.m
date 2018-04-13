%reduces an image to required size starting with vertical then horizontal
%using graph cut implementation with backward energy/forward energy
function reduced_img = simpleReduceImageGC(output_size, img, mask_maintain, type)
    n = size(img,1);
    m = size(img,2);
    
    n_desired = output_size(1);
    m_desired = output_size(2);
    
    desired_size = [n-n_desired, m-m_desired];
   
    r = n-n_desired;
    c = m-m_desired;
    
    k = desired_size(1);
    
    for p=1:k
        %construct adj. matrix of image graph
        if strcmp(type, 'BE')
            g = constructImageGraphHorizontalSeamsBE(img);
        else
            g = constructImageGraphHorizontalSeamsFE(img);
        end

        s = 1;
        t = size(g.Nodes,1);

        %compute max-flow/min-cut
        [~,~,cs,~] = maxflow(g,s,t);
        cs = cs - 1;

        %reconstruct pixels into cs and ct 
        mask = zeros(size(img,1), size(img,2));

        for i=2:length(cs)
            y = mod(cs(i), size(img,1));
            if y == 0
                y = size(img,1);
            end
            x = ((cs(i)-y)/size(img,1))+1;

            mask(y,x) = 1;
        end

        mask = logical(mask);
        mask = ~mask;

        %now get the points of the vertical seams
        min_seam_loc = zeros(size(mask,2),2);

        for i=1:size(mask,2)
            [row, col] = find(mask(:,i) == 1);
            row = row(1);

            if isempty(row)
                min_seam_loc(i,:) = [i, size(img,1)];
            else
                min_seam_loc(i,:) = [i, row-1];
            end
        end

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
        updated_img = zeros(size(img,1)-1, size(img,2), size(img,3));
        for j=1:size(mask_maintain,2)
            mask2(:,j) = mask_maintain(new_mask(:,j),j);
            updated_img(:,j,1) = img(new_mask(:,j),j,1);
            updated_img(:,j,2) = img(new_mask(:,j),j,2);
            updated_img(:,j,3) = img(new_mask(:,j),j,3);
        end

        mask_maintain = mask2;
        img = updated_img;
    end
    
    k = desired_size(2);
    
    for p=1:k
        %%%%%%%%%%%%%%%%%%%VERTICAL SEAM CASE%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %construct adj. matrix of image graph
        if strcmp(type, 'BE')
            g = constructImageGraphVerticalSeamsBE(img);
        else
            g = constructImageGraphVerticalSeamsFE(img);
        end
        
        s = 1;
        t = size(g.Nodes,1);

        %compute max-flow/min-cut
        [~,~,cs,~] = maxflow(g,s,t);
        cs = cs - 1;
        clear g; 
        %reconstruct pixels into cs and ct 
        mask = zeros(size(img,1), size(img,2));

        for i=2:length(cs)
            y = mod(cs(i), size(img,1));
            if y == 0
                y = size(img,1);
            end
            x = ((cs(i)-y)/size(img,1))+1;

            mask(y,x) = 1;
        end

        mask = logical(mask);
        mask = ~mask;

        %now get the points of the vertical seams
        min_seam_loc = zeros(size(mask,1),2);

        for j=1:size(mask,1)
            [row, col] = find(mask(j,:) == 1);
            col = col(1);

            if isempty(col)
                min_seam_loc(j,:) = [size(img,2), j];
            else
                min_seam_loc(j,:) = [col-1, j];
            end
        end

        %create mask for pixels that are part of the seam
        new_mask = zeros(size(mask_maintain,1), size(mask_maintain,2));
        for q=1:size(min_seam_loc,1)
            col = min_seam_loc(q,1);
            row = min_seam_loc(q,2);

            new_mask(row, col) = 1;
        end

        new_mask = logical(new_mask);
        new_mask = ~new_mask;

        %now create the updated mask
        mask2 = zeros(size(mask_maintain,1), size(mask_maintain,2)-1);
        updated_img = zeros(size(img,1), size(img,2)-1, size(img,3));
        for t=1:size(mask_maintain,1)
            mask2(t,:) = mask_maintain(t,new_mask(t,:));
            updated_img(t,:,1) = img(t,new_mask(t,:),1);
            updated_img(t,:,2) = img(t,new_mask(t,:),2);
            updated_img(t,:,3) = img(t,new_mask(t,:),3);
        end
        mask_maintain = mask2;
        img = updated_img;
    end
    
    reduced_img = img;
end