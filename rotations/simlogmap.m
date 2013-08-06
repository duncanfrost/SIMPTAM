function [ w,s,v ] = simlogmap(in)


Rin = in(1:3,1:3);

scale = norm(Rin);
s = log(scale);

in2 = in;
in2(1:3,1:4) = in2(1:3,1:4)/scale;

mu = logmap(in2);

w = mu(1:3);
v = mu(4:6);

end
