function [ points ] = generateworldpoints2()
%GENERATEWORLDPOINTS Generates some world points

pointCount = 0;
ymin = -5; 
ymax = 5;
xmin = -36;
xmax = 4;
zmin = -20;
zmax = 20;

pdensity = 8;

Corners = [xmin ymin zmin; xmin ymax zmin; xmax ymin zmin]';
wall1 = pointcloudplane(Corners, pdensity);

for i = 1:size(wall1,2)
    pointCount = pointCount + 1;
    points(pointCount).id = pointCount;
    points(pointCount).location = wall1(:,i);
end

Corners = [xmax ymin zmin; xmax ymax zmin; xmax ymin zmax]';
wall1 = pointcloudplane(Corners, pdensity);

for i = 1:size(wall1,2)
    pointCount = pointCount + 1;
    points(pointCount).id = pointCount;
    points(pointCount).location = wall1(:,i);
end

Corners = [xmin ymin zmax; xmin ymax zmax; xmax ymin zmax]';
wall1 = pointcloudplane(Corners, pdensity);

for i = 1:size(wall1,2)
    pointCount = pointCount + 1;
    points(pointCount).id = pointCount;
    points(pointCount).location = wall1(:,i);
end

Corners = [xmin ymin zmin; xmin ymax zmin; xmin ymin zmax]';
wall1 = pointcloudplane(Corners, pdensity);

for i = 1:size(wall1,2)
    pointCount = pointCount + 1;
    points(pointCount).id = pointCount;
    points(pointCount).location = wall1(:,i);
end








end

