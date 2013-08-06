function [ Camera ] = movecamera(Camera, dt, dtheta, absolute)
%MOVECAMERA moves the world camera by the given vector



t = Camera.E(1:3,4);
R = Camera.E(1:3,1:3);
t_w = -R'*t;

    

if ~isempty(dt)
    dt_w = Camera.E\dt;
    if ~absolute
        t_w = t_w + dt_w(1:3);    
    else
        t_w = dt(1:3);
    end
end


if ~absolute
        Camera.thetay = Camera.thetay + dtheta;
else
        Camera.thetay = dtheta;
end


Rx = [1 0 0; 0 cos(Camera.thetax) sin(Camera.thetax); 0 -sin(Camera.thetax) cos(Camera.thetax)];
Ry = [cos(Camera.thetay) 0 -sin(Camera.thetay); 0 1 0; sin(Camera.thetay) 0 cos(Camera.thetay)];
Rz = [cos(Camera.thetaz) sin(Camera.thetaz) 0; -sin(Camera.thetaz) cos(Camera.thetaz) 0; 0 0 1];
R = Rx*Ry*Rz;



t = -R*t_w;
Camera.E = [R t; 0 0 0 1];

end

