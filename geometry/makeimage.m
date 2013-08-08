function [ImagePoints] = makeimage(Camera, World, noise, associate)
kfimpointcount = 0;
for i = 1:length(World.points)
    ImagePoint = projectpoint(Camera, World.points(i),noise, associate);
    if (~isempty(ImagePoint))
        kfimpointcount = kfimpointcount + 1;
        ImagePoints(kfimpointcount) = ImagePoint;
    end
end
end