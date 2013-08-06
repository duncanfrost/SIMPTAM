function [translation, angle] = genpath(time, dtheta, radius, type)


switch type
    
    
    case 'normalcircle'
    angle = pi/2 - dtheta*(time/dtheta);
    translation = [radius*cos(time) 0 radius*sin(time) 1]';
    case 'tangentcircle'
        angle = 0 - dtheta*(time/dtheta);
    translation = [radius*cos(time) 0 radius*sin(time) 1]';
    case 'straight'
        angle = 0;
        translation = [0 0 100/(2*pi)*time 1]';
end




end

