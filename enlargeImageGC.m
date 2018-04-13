%enlarges an image using graph cut implementation
function enlarged_img = enlargeImageGC(output_size, img, type)
    enlarged_img = img;
    orig_img = img;
    
    n = size(img,1);
    m = size(img,2);
    
    n_desired = output_size(1);
    m_desired = output_size(2);
    
    desired_size = [n_desired-n, m_desired-m];
    %remove rows
    iters = desired_size(1);
    seams = {};
    index_map = zeros(size(enlarged_img,1), size(enlarged_img,2));
    
    for j=1:size(enlarged_img,1)
        index_map(j,:) = j;
    end
    
    for v=1:iters
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
        new_mask = zeros(size(img,1), size(img,2));
        for q=1:size(min_seam_loc,1)
            row = min_seam_loc(q,2);
            col = min_seam_loc(q,1);

            new_mask(row, col) = 1;
        end
        
        new_mask = logical(new_mask);
        new_mask = ~new_mask;
        
        %update seam locations according to index map
        for q=1:size(min_seam_loc,1)
            row = min_seam_loc(q,2);
            col = min_seam_loc(q,1);
            
            min_seam_loc(q,:) = [q, index_map(row,q)];
        end
        
        %now create the updated img
        updated_img = zeros(size(img,1)-1, size(img,2), size(img,3));
        updated_imap = zeros(size(img,1)-1, size(img,2));
        for j=1:size(img,2)
            updated_img(:,j,1) = img(new_mask(:,j),j,1);
            updated_img(:,j,2) = img(new_mask(:,j),j,2);
            updated_img(:,j,3) = img(new_mask(:,j),j,3);
            
            updated_imap(:,j) = index_map(new_mask(:,j),j);
        end

        img = updated_img;
        index_map = updated_imap;
        
        inc = length(seams);
        seams(inc+1).loc = min_seam_loc;
    end
    
    %construct large mask for seams
    large_mask = zeros(n, m);
    for b=1:length(seams)
        for q=1:size(min_seam_loc,1)
            row = seams(b).loc(q,2);
            col = seams(b).loc(q,1);

            large_mask(row, col) = 1;
        end
    end
    
    updated_e_img = zeros(size(orig_img,1)+iters, size(orig_img,2), size(enlarged_img,3));
    for j=1:size(large_mask,2)
        bits = find(large_mask(:,j) == 1);
        
        %do for the first bit
        if bits(1) == size(large_mask,1)
            bits(1) = bits(1) - 1;
        end
        avg_s = (orig_img(bits(1),j,1) + orig_img(bits(1)+1,j,1))/2;
        updated_e_img(1:(bits(1)+1),j,1) = [orig_img(1:bits(1),j,1); avg_s];
        
        avg_s = (orig_img(bits(1),j,2) + orig_img(bits(1)+1,j,2))/2;
        updated_e_img(1:(bits(1)+1),j,2) = [orig_img(1:bits(1),j,2); avg_s];
        
        avg_s = (orig_img(bits(1),j,3) + orig_img(bits(1)+1,j,3))/2;
        updated_e_img(1:(bits(1)+1),j,3) = [orig_img(1:bits(1),j,3); avg_s];
        
        prev_row = bits(1) + 2;
        for i=2:length(bits)
            if bits(i) == size(large_mask,1)
                bits(i) = bits(i) - 1;
            end
            next_row = prev_row + bits(i) - bits(i-1);
            
            avg_s = (orig_img(bits(i),j,1) + orig_img(bits(i)+1,j,1))/2;
            updated_e_img((prev_row):(next_row),j,1) = [orig_img((bits(i-1)+1):bits(i),j,1); avg_s];
            
            avg_s = (orig_img(bits(i),j,2) + orig_img(bits(i)+1,j,2))/2;
            updated_e_img((prev_row):(next_row),j,2) = [orig_img((bits(i-1)+1):bits(i),j,2); avg_s];
            
            avg_s = (orig_img(bits(i),j,3) + orig_img(bits(i)+1,j,3))/2;
            updated_e_img((prev_row):(next_row),j,3) = [orig_img((bits(i-1)+1):bits(i),j,3); avg_s];
            
            prev_row = next_row+1;
        end
        
        %now finish padding the rest of the img
        i=length(bits);
        updated_e_img((prev_row):end,j,1) = orig_img((bits(i)+1):end,j,1);
        updated_e_img((prev_row):end,j,2) = orig_img((bits(i)+1):end,j,2);
        updated_e_img((prev_row):end,j,3) = orig_img((bits(i)+1):end,j,3);
    end

    enlarged_img = updated_e_img;     
    img = updated_e_img;
    orig_img = updated_e_img;
    
    iters = desired_size(2);
    %remove columns
    seams = {};
    index_map = zeros(size(enlarged_img,1), size(enlarged_img,2));
    
    for i=1:size(enlarged_img,2)
        index_map(:,i) = i;
    end
    
    for v=1:iters
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
        new_mask = zeros(size(img,1), size(img,2));
        for q=1:size(min_seam_loc,1)
            col = min_seam_loc(q,1);
            row = min_seam_loc(q,2);

            new_mask(row, col) = 1;
        end

        new_mask = logical(new_mask);
        new_mask = ~new_mask;

        %update seam locations according to index map
        for q=1:size(min_seam_loc,1)
            row = min_seam_loc(q,2);
            col = min_seam_loc(q,1);
            
            min_seam_loc(q,:) = [index_map(q,col), q];
        end
        
        %now create the updated mask
        updated_img = zeros(size(img,1), size(img,2)-1, size(img,3));
        updated_imap = zeros(size(img,1), size(img,2)-1);
        for t=1:size(img,1)
            updated_img(t,:,1) = img(t,new_mask(t,:),1);
            updated_img(t,:,2) = img(t,new_mask(t,:),2);
            updated_img(t,:,3) = img(t,new_mask(t,:),3);
            
            updated_imap(t,:) = index_map(t,new_mask(t,:));
        end
        
        img = updated_img;
        index_map = updated_imap;
               
        seams(length(seams)+1).loc = min_seam_loc;
    end
    
    %construct large mask for seams
    large_mask = zeros(size(orig_img,1), size(orig_img,2));
    for b=1:length(seams)
        for q=1:size(min_seam_loc,1)
            row = seams(b).loc(q,2);
            col = seams(b).loc(q,1);

            large_mask(row, col) = 1;
        end
    end
       
    updated_e_img = zeros(size(enlarged_img,1), size(enlarged_img,2)+iters, size(enlarged_img,3));
    for t=1:size(img,1)
        bits = find(large_mask(t,:) == 1);
        
        %do for the first bit
        if bits(1) == size(large_mask,2)
            bits(1) = bits(1) - 1;
        end
        
        %do for the first bit
        avg_s = (orig_img(t,bits(1),1) + orig_img(t,bits(1)+1,1))/2;
        updated_e_img(t,1:(bits(1)+1),1) = [orig_img(t,1:bits(1),1), avg_s];
        
        avg_s = (orig_img(t,bits(1),2) + orig_img(t,bits(1)+1,2))/2;
        updated_e_img(t,1:(bits(1)+1),2) = [orig_img(t,1:bits(1),2), avg_s];
        
        avg_s = (orig_img(t,bits(1),3) + orig_img(t,bits(1)+1,3))/2;
        updated_e_img(t,1:(bits(1)+1),3) = [orig_img(t,1:bits(1),3), avg_s];
        
        prev_col = bits(1) + 2;
        for i=2:length(bits)
            if bits(i) == size(large_mask,2)
                bits(i) = bits(i) - 1;
            end
            next_col = prev_col + bits(i) - bits(i-1);
            
            avg_s = (orig_img(t,bits(i),1) + orig_img(t,bits(i)+1,1))/2;
            updated_e_img(t,(prev_col):(next_col),1) = [orig_img(t,(bits(i-1)+1):bits(i),1), avg_s];
            
            avg_s = (orig_img(t,bits(i),2) + orig_img(t,bits(i)+1,2))/2;
            updated_e_img(t,(prev_col):(next_col),2) = [orig_img(t,(bits(i-1)+1):bits(i),2), avg_s];
            
            avg_s = (orig_img(t,bits(i),3) + orig_img(t,bits(i)+1,3))/2;
            updated_e_img(t,(prev_col):(next_col),3) = [orig_img(t,(bits(i-1)+1):bits(i),3), avg_s];  
            
            prev_col = next_col + 1;
        end
        
        %now finish padding the rest of the img
        i=length(bits);
        updated_e_img(t,(prev_col):end,1) = orig_img(t,(bits(i)+1):end,1);
        updated_e_img(t,(prev_col):end,2) = orig_img(t,(bits(i)+1):end,2);
        updated_e_img(t,(prev_col):end,3) = orig_img(t,(bits(i)+1):end,3);
    end

    enlarged_img = updated_e_img;
end