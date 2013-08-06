function [  ] = view3d( handles )
%VIEW3D Summary of this function goes here
%   Detailed explanation goes here
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

ptamPoints = [];
worldPoints = [];


for i = 1:size(PTAM.Map.points,2)
    ptamPoints(1,i) = PTAM.Map.points(i).location(1);
    ptamPoints(2,i) = PTAM.Map.points(i).location(2);
    ptamPoints(3,i) = PTAM.Map.points(i).location(3);
end

for i = 1:size(World.Map.points,2)
    worldPoints(1,i) = World.Map.points(i).location(1);
    worldPoints(2,i) = World.Map.points(i).location(2);
    worldPoints(3,i) = World.Map.points(i).location(3);
end


figure

mag = 1;
plot3(mag*worldPoints(1,:),mag*worldPoints(2,:),mag*worldPoints(3,:),'bo');
hold on
plot3(mag*ptamPoints(1,:),mag*ptamPoints(2,:),mag*ptamPoints(3,:),'ro');
% for i = 1:size(PTAM.Map.points,2)
%     wx = worldPoints(1,i);
%     wy = worldPoints(2,i);
%     wz = worldPoints(3,i);
%     px = ptamPoints(1,i);
%     py = ptamPoints(2,i);
%     pz = ptamPoints(3,i);
%     
%     plot3([wx px],[wy py],[wz pz],'g-');
% end
end

