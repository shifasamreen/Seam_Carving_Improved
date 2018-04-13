function img_graph = constructImageGraphVerticalSeamsBE(img)
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
    
    %inf weights at left columns
    sp = -1*ones(size(img,1), 3);
    for j=1:size(img,1)
        i=1;
        curr_pos = (i-1)*size(img,1) + j + 1; 
        
        sp(j,:) = [1,curr_pos,inf_weights];
    end
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
    
    %inf weights at right columns
    sp = -1*ones(size(img,1), 3);
    for j=1:size(img,1)
        i=size(img,2);
        curr_pos = (i-1)*size(img,1) + j + 1; 
        
        sp(j,:) = [curr_pos,n,inf_weights];
    end
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
    
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
            elseif j==size(img,1)
                sp(t,:) = [curr_pos, right_pos,energy(j,i)];
                sp(t+1,:) = [right_pos, curr_pos,inf_weights];
            else
                sp(t,:) = [curr_pos, right_pos, energy(j,i)];
                sp(t+1,:) = [right_pos, curr_pos,inf_weights];
                sp(t+2,:) = [right_pos, bottom_pos,inf_weights];
                sp(t+3,:) = [br_pos, curr_pos,inf_weights];
            end
            t = t + 4;
        end
    end
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
        
    img_graph = g;
end