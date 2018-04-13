%read img
img = im2single(imread('images/cameraOnTable_original.jpg'));

img = imresize(img, [200, 200]);

output_size = [size(img,1) - 1, size(img,2)];
tic
    img = simpleReduceImageGC(output_size, img, zeros(size(img)), 'BE');
toc

tic
showGraphCutsVideoFigure(vframes(1:4), direction, type)
toc

%%%%%%%%%%%%%%%%%%%VERTICAL SEAM CASE%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construct adj. matrix of image graph
img_graph = constructImageGraphVerticalSeamsFE(img);
s = 1;
t = size(img_graph,1);

%construct digraph
g = digraph(img_graph);

%compute max-flow/min-cut
[mf,~,cs,ct] = maxflow(g,s,t);
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

imshow(mask);
hold on

%now get the points of the vertical seams
min_seam_loc = zeros(size(mask,1),2);

for j=1:size(mask,1)
    [r, c] = find(mask(j,:) == 1);
    c = c(1);
    
    if isempty(c)
        min_seam_loc(j,:) = [size(img,2), j];
    else
        min_seam_loc(j,:) = [c-1, j];
    end
end

plot(min_seam_loc(:,1), min_seam_loc(:,2), 'r.', 'Linewidth', 3);

%%%%%%%%%%%%%%%%%%%HORIZONTAL SEAM CASE%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construct adj. matrix of image graph
img_graph = constructImageGraphHorizontalSeamsFE(img);
s = 1;
t = size(img_graph,1);

%construct digraph
g = digraph(img_graph);

%compute max-flow/min-cut
[mf,~,cs,ct] = maxflow(g,s,t);
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

imshow(mask);
hold on

%now get the points of the vertical seams
min_seam_loc = zeros(size(mask,1),2);

for i=1:size(mask,2)
    [r, c] = find(mask(:,i) == 1);
    r = r(1);
    
    if isempty(r)
        min_seam_loc(i,:) = [i, size(img,1)];
    else
        min_seam_loc(i,:) = [i, r-1];
    end
end

plot(min_seam_loc(:,1), min_seam_loc(:,2), 'r.', 'Linewidth', 3);