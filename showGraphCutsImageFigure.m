%shows the graph cut representation of image
function showGraphCutsImageFigure(img, direction, type)

if strcmp(direction, 'horizontal')
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
    
    figure;
    imshow(mask);
    hold on
    plot(min_seam_loc(:,1), min_seam_loc(:,2), 'r.');
else
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
    
    figure;
    imshow(mask);
    hold on
    plot(min_seam_loc(:,1), min_seam_loc(:,2), 'r.');
end