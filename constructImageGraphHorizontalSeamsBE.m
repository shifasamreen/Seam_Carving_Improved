function img_graph = constructImageGraphHorizontalSeamsBE(img)
    n = size(img,1)*size(img,2)+2;
    
    g = digraph();
    %add nodes
    g = addnode(g, n);
    
    inf_weights = 1000;
    
    %compute enery of image
    energy = gradientEnergy(img);
    
    %normalize
    max_vote = max(max(energy));
    min_vote = min(min(energy));

    energy = (energy - min_vote)/(max_vote - min_vote);
    
    %inf weights at top row
    sp = -1*ones(size(img,2), 3);
    for i=1:size(img,2)
        j=1;
        curr_pos = (i-1)*size(img,1) + j + 1; 
        
        sp(i,:) = [1,curr_pos,inf_weights];
    end
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
    
    %inf weights at bottom row
    sp = -1*ones(size(img,2), 3);
    for i=1:size(img,2)
        j=size(img,1);
        curr_pos = (i-1)*size(img,1) + j + 1; 
        
        sp(i,:) = [curr_pos,n,inf_weights];
    end
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
    
    tic
    %construct neighbors
    sp = -1*ones(4*size(img,1)*size(img,2), 3);
    t = 1;
    for i=1:size(img,2)
        for j=1:size(img,1)
            curr_pos = (i-1)*size(img,1) + j + 1;
            bottom_pos = (i-1)*size(img,1) + (j+1) + 1;
            br_pos = (i)*size(img,1) + (j+1) + 1;
            right_pos = (i)*size(img,1) + j + 1;

            if i==size(img,2) && j == size(img,1)
                %do nothing
            elseif i==size(img,2)
                sp(t,:) = [curr_pos, bottom_pos,energy(j,i)];
                sp(t+1,:) = [bottom_pos, curr_pos,inf_weights];
            elseif j==size(img,1)
            else
                sp(t,:) = [br_pos, curr_pos,inf_weights];
                sp(t+1,:) = [curr_pos, bottom_pos,energy(j,i)];
                sp(t+2,:) = [bottom_pos, curr_pos,inf_weights];
                sp(t+3,:) = [bottom_pos, right_pos,inf_weights];
            end
            t = t + 4;
        end
    end
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
    img_graph = g;
end