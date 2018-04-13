%computes gradient energy of rgb image
function energy = gradientEnergy(img)
    [FX, FY] = gradient(img);

    %compute e_1 energy for entire image
    e_1 = abs(FX) + abs(FY);

    energy = zeros(size(e_1,1), size(e_1,2));
    energy = energy + e_1(:,:,1) + e_1(:,:,2) + e_1(:,:,3);
% 
%     max_vote = max(max(e_c));
%     min_vote = min(min(e_c));
% 
%     e_c = (e_c - min_vote)/(max_vote - min_vote);
end