function [ PTAM ] = settogt( PTAM, World )


for i = 1:size(World.KeyFrames,2)
    PTAM.KeyFrames(i).Camera = World.KeyFrames(i).Camera;
end

for i = 1:size(World.Map.points,2)
    for j = 1:size(PTAM.Map.points,2)
        if (World.Map.points(i).id == PTAM.Map.points(j).gtid)
            
            PTAM.Map.points(j).location = World.Map.points(i).location;
            break;
        end
    end
end

PTAM.Camera = World.Camera;


end

