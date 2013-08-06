function [ centre ] = camcentre(E)
%CAMCENTRE Calculates a cameras centre from E
t = E(1:3,4);
R = E(1:3,1:3);

centre = -R'*t;



end

