function [ImagePoint] = projectpoint(Camera, WorldPoint,noise)
ImagePoint = [];
X = WorldPoint.location;
nX = Camera.E*X;

if norm(nX(1:3)) < 15

    nX = nX ./ nX(4);
    if (nX(3) > Camera.f)
        x = Camera.K*Camera.E(1:3,:)*X;
        x = x./x(3);

        x2 = double(Camera.E(1:3,:)*X);
        x2 = x2./x2(3);


        x(1) = x(1) + randn*noise;
        x(2) = x(2) + randn*noise;

        if (x(1) > 1 && x(1) < 640 && x(2) > 1 && x(2) < 480)
            ImagePoint.id = WorldPoint.id;
            ImagePoint.location = [x(1) x(2) 1]';
            ImagePoint.location2 = [double(x2(1)) double(x2(2)) 1]';
            ImagePoint.X = X;
        end
    end
    
else
    ImagePoint = [];
end

end
    
    