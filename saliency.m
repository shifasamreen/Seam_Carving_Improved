function sm = saliency( img )

% Read image and blur it with a 3x3 or 5x5 Gaussian filter
gfrgb = imfilter(img, fspecial('gaussian', 3, 3), 'symmetric', 'conv');

% Perform sRGB to CIE Lab color space conversion (using D65)
cform = makecform('srgb2lab', 'AdaptedWhitePoint', whitepoint('d65'));
lab = applycform(gfrgb,cform);

% Compute Lab average values 
l = double(lab(:,:,1)); lm = mean(mean(l));
a = double(lab(:,:,2)); am = mean(mean(a));
b = double(lab(:,:,3)); bm = mean(mean(b));


% Finally compute the saliency map and display it.
sm = (l-lm).^2 + (a-am).^2 + (b-bm).^2;
%imshow(sm);
end

