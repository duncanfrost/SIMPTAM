function [ points ] = generateworldpoints3(r,h)
%GENERATEWORLDPOINTS Generates some world points

points = [];

% 
% for i = 1:300
%     
%     
%     angle = rand*2*pi;
%     x = r*cos(angle);
%     z = r*sin(angle);
%     
%     y = rand*2*h - h;
%  
%     
%     points(i).id = i;
%     points(i).estids = [];
%     points(i).location = [x y z 1]';
%     
% end

    






[X,Y,Z] = cylinder(r,100);

count = 0;
for i = 1:100
    for h = -1:2:1
        count = count + 1;
        points(count).location = [X(1,i) h Y(1,i) 1]';
        points(i).estids = [];
        points(count).id = count;
    end
end




end

