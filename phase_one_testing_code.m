%read image
image_file_dir = 'images/christmas_original.png';
img = im2single(imread(image_file_dir));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PART 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gradient
[FX, FY] = gradient(img);

%compute e_1 energy for entire image
e_1 = abs(FX) + abs(FY);

e_c = zeros(size(e_1,1), size(e_1,2));
e_c = e_c + e_1(:,:,1) + e_1(:,:,2) + e_1(:,:,3);

max_vote = max(max(e_c));
min_vote = min(min(e_c));

e_c = (e_c - min_vote)/(max_vote - min_vote);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PART 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%perform dynamic programming to compute min vertical seam
M = zeros(size(img,1), size(img,2));
M(1,:) = e_c(1,:);

r = size(img,1);
c = size(img,2);

for i=2:r
    for j=1:c
        if j-1 == 0
            M(i,j) = e_c(i,j) + min(M(i-1,j), M(i-1,j+1)); 
        elseif j == c
            M(i,j) = e_c(i,j) + min(M(i-1,j-1), M(i-1,j));    
        else
            M(i,j) = e_c(i,j) + min(M(i-1,j-1), min(M(i-1,j), M(i-1,j+1)));
        end        
    end
end

%store the pixel locations for min seam
min_seam_loc = zeros(r, 2);

[v, I] = min(M(row,:));
min_at_prev_row = I(1);
min_seam_loc(r,:) = [r min_at_prev_row];

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

%draw seam
f = figure();
imshow(img);
hold on;
plot(min_seam_loc(:, 2), min_seam_loc(:, 1), 'r.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PART 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%perform dynamic programming to compute min horizontal seam
M = zeros(size(img,1), size(img,2));
M(:,1) = e_c(:,1);

r = size(img,1);
c = size(img,2);

for i=1:r
    for j=2:c
        if i-1 == 0
            M(i,j) = e_c(i,j) + min(M(i,j-1), M(i+1,j-1)); 
        elseif i == r
            M(i,j) = e_c(i,j) + min(M(i-1,j-1), M(i,j-1));    
        else
            M(i,j) = e_c(i,j) + min(M(i-1,j-1), min(M(i,j-1), M(i+1,j-1)));
        end        
    end
end

%store the pixel locations for min seam
min_seam_loc = zeros(c, 2);

[v, I] = min(M(:,c));
min_at_prev_col = I(1);
min_seam_loc(c,:) = [c min_at_prev_col];

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

%draw seam
f = figure();
imshow(img);
hold on;
plot(min_seam_loc(:, 1), min_seam_loc(:, 2), 'r.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PART 4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%