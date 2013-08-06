function [C] = crossnot(w)

C = zeros(3,3);

C(1,2) = -w(3);
C(2,1) = w(3);

C(1,3) = w(2);
C(3,1) = -w(2);

C(3,2) = w(1);
C(2,3) = -w(1);

end
