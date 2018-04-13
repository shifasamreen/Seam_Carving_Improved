function img_graph = constructImageGraphHorizontalSeamsFE(img)
    n = size(img,1)*size(img,2)+2;
    
    g = digraph();
    %add nodes
    g = addnode(g, n);
    
    inf_weights = 1000;
        
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
    
    %construct neighbors
    sp = -1*ones(6*size(img,1)*size(img,2), 3);
    t = 1;
    for i=1:size(img,2)
        for j=1:size(img,1)
            curr_pos = (i-1)*size(img,1) + j + 1;
            bottom_pos = (i-1)*size(img,1) + (j+1) + 1;
            br_pos = (i)*size(img,1) + (j+1) + 1;
            right_pos = (i)*size(img,1) + j + 1;
            
            if i==1
                if j == 1
                    sp(t,:) = [curr_pos, right_pos,abs(img(j,i+1,1) - img(j,i,1)) + ...
                                         abs(img(j,i+1,2) - img(j,i,2)) + ...
                                         abs(img(j,i+1,3) - img(j,i,3))];
                    sp(t+1,:) = [br_pos, curr_pos,inf_weights];
                    sp(t+2,:) = [curr_pos, bottom_pos,abs(img(j+1,i,1) - img(j,i,1)) + ...
                                             abs(img(j+1,i,2) - img(j,i,2)) + ...
                                             abs(img(j+1,i,3) - img(j,i,3))];
                    sp(t+3,:) = [bottom_pos, curr_pos,inf_weights];
                    sp(t+4,:) = [bottom_pos, right_pos,inf_weights];
                elseif j==size(img,1)
                    sp(t,:) = [curr_pos, right_pos,abs(img(j,i+1,1) - img(j,i,1)) + ...
                                         abs(img(j,i+1,2) - img(j,i,2)) + ...
                                         abs(img(j,i+1,3) - img(j,i,3))];
                else
                    sp(t,:) = [curr_pos, right_pos,abs(img(j,i+1,1) - img(j-1,i,1)) + ...
                                         abs(img(j,i+1,2) - img(j-1,i,2)) + ...
                                         abs(img(j,i+1,3) - img(j-1,i,3))];
                    sp(t+1,:) = [right_pos, curr_pos,abs(img(j,i,1) - img(j-1,i,1)) + ...
                                             abs(img(j,i,2) - img(j-1,i,2)) + ...
                                             abs(img(j,i,3) - img(j-1,i,3))];
                    sp(t+2,:) = [br_pos, curr_pos,inf_weights];
                    sp(t+3,:) = [curr_pos, bottom_pos,abs(img(j+1,i,1) - img(j-1,i,1)) + ...
                                             abs(img(j+1,i,2) - img(j-1,i,2)) + ...
                                             abs(img(j+1,i,3) - img(j-1,i,3))];
                    sp(t+4,:) = [bottom_pos, curr_pos,inf_weights];
                    sp(t+5,:) = [bottom_pos, right_pos,inf_weights];
                end
            elseif j==1
                if i == size(img,2)
                    sp(t,:) = [curr_pos, bottom_pos,abs(img(j+1,i,1) - img(j,i,1)) + ...
                                             abs(img(j+1,i,2) - img(j,i,2)) + ...
                                             abs(img(j+1,i,3) - img(j,i,3))];
                    sp(t+1,:) = [bottom_pos, curr_pos,inf_weights];

                else
                    sp(t,:) = [curr_pos, right_pos,abs(img(j,i+1,1) - img(j,i,1)) + ...
                                             abs(img(j,i+1,2) - img(j,i,2)) + ...
                                             abs(img(j,i+1,3) - img(j,i,3))];
                    sp(t+1,:) = [right_pos, curr_pos,abs(img(j,i-1,1) - img(j,i,1)) + ...
                                             abs(img(j,i-1,2) - img(j,i,2)) + ...
                                             abs(img(j,i-1,3) - img(j,i,3))];
                    sp(t+2,:) = [br_pos, curr_pos,inf_weights];
                    sp(t+3,:) = [curr_pos, bottom_pos,abs(img(j+1,i,1) - img(j,i,1)) + ...
                                             abs(img(j+1,i,2) - img(j,i,2)) + ...
                                             abs(img(j+1,i,3) - img(j,i,3))];
                    sp(t+4,:) = [bottom_pos, curr_pos,inf_weights];
                    sp(t+5,:) = [bottom_pos, right_pos,inf_weights];
                end
            elseif i==size(img,2) && j == size(img,1)
                %do nothing
            elseif i==size(img,2)
                sp(t,:) = [curr_pos, bottom_pos,abs(img(j+1,i,1) - img(j-1,i,1)) + ...
                                         abs(img(j+1,i,2) - img(j-1,i,2)) + ...
                                         abs(img(j+1,i,3) - img(j-1,i,3))];
                sp(t+1,:) = [bottom_pos, curr_pos,inf_weights];
            elseif j==size(img,1)
                sp(t,:) = [curr_pos, right_pos,abs(img(j,i+1,1) - img(j-1,i,1)) + ...
                                         abs(img(j,i+1,2) - img(j-1,i,2)) + ...
                                         abs(img(j,i+1,3) - img(j-1,i,3))];
                sp(t+1,:) = [right_pos, curr_pos,abs(img(j,i-1,1) - img(j-1,i,1)) + ...
                                         abs(img(j,i-1,2) - img(j-1,i,2)) + ...
                                         abs(img(j,i-1,3) - img(j-1,i,3))];
            else
                sp(t,:) = [curr_pos, right_pos,abs(img(j,i+1,1) - img(j-1,i,1)) + ...
                                         abs(img(j,i+1,2) - img(j-1,i,2)) + ...
                                         abs(img(j,i+1,3) - img(j-1,i,3))];
                sp(t+1,:) = [right_pos, curr_pos,abs(img(j,i-1,1) - img(j-1,i,1)) + ...
                                         abs(img(j,i-1,2) - img(j-1,i,2)) + ...
                                         abs(img(j,i-1,3) - img(j-1,i,3))];
                sp(t+2,:) = [br_pos, curr_pos,inf_weights];
                sp(t+3,:) = [curr_pos, bottom_pos,abs(img(j+1,i,1) - img(j-1,i,1)) + ...
                                         abs(img(j+1,i,2) - img(j-1,i,2)) + ...
                                         abs(img(j+1,i,3) - img(j-1,i,3))];
                sp(t+4,:) = [bottom_pos, curr_pos,inf_weights];
                sp(t+5,:) = [bottom_pos, right_pos,inf_weights];
            end
            t = t + 6;
        end
    end
    
    sp = sp(sp(:,1) ~= -1,:);
    g = addedge(g, sp(:,1)', sp(:,2)', sp(:,3)');
    
    img_graph = g;
end