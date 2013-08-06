function [ImagePoints] = makeimage(Camera, World, noise)
kfimpointcount = 0;
ImagePoints = struct('id',1,'location',[0 0 1]','location2',[0 0 1]' ,'X',[0 0 0 1]');
for i = 1:length(World.points)
    ImagePoint = projectpoint(Camera, World.points(i),noise);
    if (~isempty(ImagePoint))
        kfimpointcount = kfimpointcount + 1;
        ImagePoints(kfimpointcount) = ImagePoint;
    end
end
end