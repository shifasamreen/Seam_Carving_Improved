%script to generate and plot T_map
img = im2single(imread('images/dolphin.jpg'));

output_size = [200 400];

n = size(img,1);
m = size(img,2);

n_desired = output_size(1);
m_desired = output_size(2);

desired_size = [n-n_desired, m-m_desired];

[T_map, T_choice_map] = optSeamOrderingTMap(desired_size, img);


max_vote = max(max(T_map));
min_vote = min(min(T_map));
tn = (T_map - min_vote) / (max_vote- min_vote);
figure;
imshow(tn)
imshow(tn, 'colormap', jet)

hold on

desired_size = [90 90];
r = desired_size(1) + 1;
c = desired_size(2)+1;
k = desired_size(1) + desired_size(2);
    
for i=1:k
    plot(c, r, 'w.');
    if(T_choice_map(r,c) == 0)
        
        c = c - 1;
    else
        r = r - 1;
    end
end

hold off;