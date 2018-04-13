%amplifies the content in an image. idea is simple. first scale the image
%by 20%, then perform seam carving to reduce the image back to original
%size.
function amplified_img = amplifyImage(img, maintain_mask, type)
profile on ;
    n = size(img,1);
    m = size(img,2);
    
    n_desired = round(1.2*n);
    m_desired = round(1.2*m);
    
    output_size = [n m];
    scaled_img = imresize(img,[n_desired m_desired]);
    maintain_mask = imresize(maintain_mask,[n_desired m_desired]);
    
    if strcmp(type, 'simple')
        scaled_img = simpleReduceImage(output_size, scaled_img, maintain_mask);
    else
        scaled_img = reduceImage(output_size, scaled_img);
    end
    amplified_img = scaled_img;
    
 profile viewer;   
img= double(img);
amplified_img=double(amplified_img);
[M, N] = size(amplified_img);
error =(amplified_img)- (img) ;
MSE = sum(sum(error .* error)) / (M * N);
fprintf('The  mean squared error is %0.4f\n',MSE);  

end