function [ output_args ] = generateframes(Path)
Map.points = generateworldpoints3(10,3);


Path.time = Path.time + Path.dtheta;
[dt, angle] = genpath(Path.time, Path.dtheta, Path.radius, Path.type);
World.Camera = movecamera(World.Camera,dt,angle,true);





end

