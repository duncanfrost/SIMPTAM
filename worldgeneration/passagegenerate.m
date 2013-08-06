function [ points ] = passagegenerate(width,length, height, npoints)


points = [];


for i = 1:npoints
    x = (2*randi([0 1]) - 1)*width;
    z = rand*length;
    y = 2*height*rand - height;
    
    points(i).id = i;
    points(i).location = [x y z 1]';
  
end



