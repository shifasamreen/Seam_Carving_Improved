function BW = lineDetection( img )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

I=rgb2gray(img);
BW = edge(I,'canny');

end

