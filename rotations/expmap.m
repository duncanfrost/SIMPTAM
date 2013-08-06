function [ out ] = expmap(mu)

v = mu(1:3);
w = mu(4:6);

theta = norm(w);


if theta == 0
    R = eye(3,3);
    V = eye(3,3);
else
    R = eye(3,3) + (sin(theta)/theta)*crossnot(w) + ((1-cos(theta))/theta^2)*(crossnot(w)^2);
    V = eye(3,3) + ((1-cos(theta))/theta^2)*crossnot(w) + ((theta-sin(theta))/theta^3)*(crossnot(w)^2);
end





out = eye(4,4);
out(1:3,1:3) = R;
out(1:3,4) = V*v;

end

