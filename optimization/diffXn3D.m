function [dXn dYn dZn] = diffXn3D(E,param)
dXn = E(1,1)*(param==1) + E(1,2)*(param==2) + E(1,3)*(param==3);
dYn = E(2,1)*(param==1) + E(2,2)*(param==2) + E(2,3)*(param==3);
dZn = E(3,1)*(param==1) + E(3,2)*(param==2) + E(3,3)*(param==3);
end

